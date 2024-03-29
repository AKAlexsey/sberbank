defmodule Sberbank.Pipeline.OperatorClient do
  @moduledoc """
  Represent behaviour of Operator client. Should be responsible for the connection
  of one operator
  """

  use GenServer

  require Logger

  @max_tickets 3
  @check_tickets_interval 500

  alias Sberbank.Customers.Ticket
  alias Sberbank.{Eventbus, OperatorTicketContext, Staff}
  alias Sberbank.Pipeline.RabbitClient
  alias Sberbank.Staff.Employer
  alias Sberbank.Utils

  @spec get_active_tickets(Employer.t()) :: list(map)
  def get_active_tickets(%{} = operator) do
    server_name = make_server_name(operator)

    GenServer.call(server_name, :get_active_tickets)
  end

  def child_spec(%{operator: %Employer{} = operator} = params) do
    server_name = make_server_name(operator)

    %{
      id: server_name,
      start: {__MODULE__, :start_link, [params]}
    }
  end

  # Users API
  def start_link(%{operator: %Employer{} = operator} = params) do
    server_name = make_server_name(operator)
    GenServer.start_link(__MODULE__, params, name: server_name)
  end

  def make_server_name(%Employer{id: id}) do
    "#{__MODULE__}_#{id}"
    |> String.to_atom()
  end

  def init(%{operator: operator}) do
    RabbitClient.subscribe_operator_to_exchanges(operator)
    RabbitClient.subscribe_to_operator_queue(operator, self())
    Eventbus.subscribe_exchanges()
    Eventbus.subscribe_tickets()
    Eventbus.subscribe_operator(operator)
    active_tickets = OperatorTicketContext.get_operator_active_tickets(operator)
    check_new_tickets(2000)

    %{competencies: competencies} = Staff.get_employer!(operator.id, [:competencies])

    {:ok,
     %{
       operator: operator,
       competencies: competencies,
       active: true,
       active_tickets: active_tickets,
       tickets_queue: :queue.new()
     }}
  end

  def handle_call(:get_active_tickets, _from, state) do
    {:reply, Map.get(state, :active_tickets), state}
  end

  # Tickets events handlers
  def handle_info(
        {:operator_leaves_ticket, %{id: leaves_operator_id}, ticket_id},
        %{operator: %{id: operator_id}} = state
      )
      when leaves_operator_id == operator_id do
    {:noreply, remove_active_ticket(state, ticket_id)}
  end

  def handle_info({:operator_leaves_ticket, _, _}, state) do
    {:noreply, state}
  end

  def handle_info({:ticket_deleted, %{id: ticket_id}}, state) do
    {:noreply, remove_active_ticket(state, ticket_id)}
  end

  def handle_info({:ticket_deactivated, %{id: ticket_id}}, state) do
    {:noreply, remove_active_ticket(state, ticket_id)}
  end

  def handle_info({:repeat_push_ticket, _}, state) do
    {:noreply, state}
  end

  # RabbitMQ event handlers
  def handle_info(
        {:basic_deliver, encoded_data, %{delivery_tag: delivery_tag}},
        %{tickets_queue: tickets_queue} = state
      ) do
    Jason.decode(encoded_data)
    |> case do
      {:ok, ticket_data} ->
        new_tickets_queue = :queue.in({ticket_data, delivery_tag}, tickets_queue)
        {:noreply, %{state | tickets_queue: new_tickets_queue}}

      {:error, reason} ->
        Logger.error(fn -> "Error parsing data for #{inspect(self())}: #{reason}" end)
        {:noreply, state}
    end
  end

  def handle_info({:basic_consume_ok, _}, state) do
    {:noreply, state}
  end

  # Repeating process
  def handle_info(
        :check_new_tickets,
        %{active: true, active_tickets: tickets, operator: operator, tickets_queue: tickets_queue} =
          state
      )
      when length(tickets) < @max_tickets do
    with {{:value, {%{"id" => ticket_id}, delivery_tag}}, new_tickets_queue} <-
           :queue.out(tickets_queue),
         {:ok, {ticket, ticket_operator}} <-
           OperatorTicketContext.add_operator_to_ticket(ticket_id, operator) do
      check_new_tickets()
      new_active_tickets = [{ticket, ticket_operator}] ++ tickets

      new_state = %{
        state
        | active_tickets: new_active_tickets,
          tickets_queue: new_tickets_queue
      }

      RabbitClient.acknowledge_message(delivery_tag)
      Eventbus.broadcast_operator_tickets_updated(operator, new_active_tickets)

      {:noreply, new_state}
    else
      {:error, reason} when is_binary(reason) ->
        {{:value, {%{"id" => _ticket_id}, delivery_tag}}, new_tickets_queue} =
          :queue.out(tickets_queue)

        RabbitClient.acknowledge_message(delivery_tag)

        check_new_tickets()
        Logger.info(fn -> "#{__MODULE__} Error linking operator to ticket: #{reason}" end)
        {:noreply, %{state | tickets_queue: new_tickets_queue}}

      {:error, :try_later} ->
        {{:value, {%{"id" => ticket_id}, delivery_tag}}, new_tickets_queue} =
          :queue.out(tickets_queue)

        Eventbus.broadcast_repeat_push_ticket(ticket_id)

        RabbitClient.acknowledge_message(delivery_tag)

        check_new_tickets()
        {:noreply, %{state | tickets_queue: new_tickets_queue}}

      {:empty, _} ->
        check_new_tickets()
        {:noreply, state}
    end
  end

  def handle_info(:check_new_tickets, state) do
    check_new_tickets()
    {:noreply, state}
  end

  # Exchanges event handlers
  def handle_info(
        {:competence_updated, old_competence, _new_competence},
        %{operator: operator, competencies: competencies} = state
      ) do
    competencies
    |> Enum.find(fn %{id: competence_id} -> competence_id == old_competence.id end)
    |> case do
      nil ->
        {:noreply, state}

      competence ->
        RabbitClient.unsubscribe_operator_from_exchange(operator, old_competence)
        RabbitClient.subscribe_operator_to_exchanges(operator)
        {:noreply, update_competence(state, competence)}
    end
  end

  def handle_info(
        {:competence_deleted, competence},
        %{operator: operator, competencies: competencies} = state
      ) do
    competencies
    |> Enum.find(fn %{id: competence_id} -> competence_id == competence.id end)
    |> case do
      nil ->
        {:noreply, state}

      competence ->
        RabbitClient.unbind_operator_topic(operator, competence)
        {:noreply, remove_competence(state, competence)}
    end
  end

  # Operator event handlers
  def handle_info(:operator_updated, %{operator: %{id: id}} = state) do
    updated_operator = Staff.get_employer!(id, [:competencies])
    %{competencies: refreshed_competencies} = updated_operator
    RabbitClient.subscribe_operator_to_exchanges(updated_operator)
    {:noreply, %{state | operator: updated_operator, competencies: refreshed_competencies}}
  end

  def handle_info({:operator_tickets_updated, _}, state) do
    {:noreply, state}
  end

  def handle_info({:initial_push_ticket, _}, state) do
    {:noreply, state}
  end

  def handle_info(unexpected_handle_info, state) do
    Logger.error(fn ->
      "Unexpected handle info: #{inspect(unexpected_handle_info, pretty: true)}\nState: #{inspect(state, pretty: true)}"
    end)

    {:noreply, state}
  end

  # Helper functions
  defp remove_active_ticket(
         %{active_tickets: active_tickets, operator: operator} = state,
         ticket_id
       ) do
    ticket_id = Utils.safe_to_integer(ticket_id)

    new_active_tickets =
      Enum.reject(active_tickets, fn {%Ticket{id: id}, _} -> id == ticket_id end)

    if active_tickets != new_active_tickets do
      Eventbus.broadcast_operator_tickets_updated(operator, new_active_tickets)
      %{state | active_tickets: new_active_tickets}
    else
      state
    end
  end

  defp update_competence(
         %{competencies: competencies} = state,
         %{id: updated_id} = updated_competence
       ) do
    new_competencies =
      competencies
      |> Enum.map(fn
        %{id: competence_id} when competence_id == updated_id ->
          updated_competence

        not_updated_competence ->
          not_updated_competence
      end)

    %{state | competencies: new_competencies}
  end

  defp remove_competence(%{competencies: competencies} = state, %{id: removed_id}) do
    new_competencies =
      Enum.reject(competencies, fn %{id: competence_id} -> competence_id == removed_id end)

    %{state | competencies: new_competencies}
  end

  defp check_new_tickets(check_interval \\ @check_tickets_interval) do
    Process.send_after(self(), :check_new_tickets, check_interval)
  end
end
