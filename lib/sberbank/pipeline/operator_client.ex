defmodule Sberbank.Pipeline.OperatorClient do
  @moduledoc """
  Represent behaviour of Operator client. Should be responsible for the connection
  of one operator
  """

  use GenServer

  require Logger

  @max_tickets 3
  @check_tickets_interval 500
  @ticket_requeue_timeout 1000

  alias Sberbank.Customers.{Ticket, TicketOperator}
  alias Sberbank.{OperatorTicketContext, Staff}
  alias Sberbank.Staff.Employer
  alias Sberbank.Pipeline.{RabbitClient, Toolkit}
  alias Sberbank.Utils

  @spec deactivate_ticket(Employer | integer, integer | binary) :: list(map)
  def deactivate_ticket(%Employer{} = operator, ticket_id) do
    operator
    |> make_server_name()
    |> GenServer.call({:deactivate_ticket, ticket_id})
  end

  def deactivate_ticket(operator_id, ticket_id) do
    Staff.get_employer(operator_id)
    |> case do
      nil ->
        {:error, "Operator with ID: #{operator_id} not found"}

      operator ->
        deactivate_ticket(operator, ticket_id)
    end
  end

  @spec leave_ticket(Employer | integer, integer | binary) :: list(map)
  def leave_ticket(%Employer{} = operator, ticket_id) do
    operator
    |> make_server_name()
    |> GenServer.call({:leave_ticket, ticket_id})
  end

  def leave_ticket(operator_id, ticket_id) do
    Staff.get_employer(operator_id)
    |> case do
      nil ->
        {:error, "Operator with ID: #{operator_id} not found"}

      operator ->
        leave_ticket(operator, ticket_id)
    end
  end

  @spec ticket_removed(Employer | integer, integer | binary) :: :ok | {:error, binary}
  def ticket_removed(%Employer{} = operator, ticket_id) do
    operator
    |> make_server_name()
    |> GenServer.cast({:ticket_removed, ticket_id})
  end

  def ticket_removed(operator_id, ticket_id) do
    Staff.get_employer(operator_id)
    |> case do
      nil ->
        {:error, "Operator with ID: #{operator_id} not found"}

      operator ->
        ticket_removed(operator, ticket_id)
    end
  end

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

  defp make_server_name(%Employer{id: id}) do
    "#{__MODULE__}_#{id}"
    |> String.to_atom()
  end

  def init(%{operator: operator}) do
    RabbitClient.subscribe_operator_to_exchanges(operator)
    RabbitClient.subscribe_to_operator_queue(operator, self())
    active_tickets = OperatorTicketContext.get_operator_active_tickets(operator)
    check_new_tickets(2000)

    {:ok,
     %{
       operator: operator,
       active: true,
       active_tickets: active_tickets,
       tickets_queue: :queue.new()
     }}
  end

  def handle_call(
        {:deactivate_ticket, ticket_id},
        _from,
        %{
          active_tickets: active_tickets
        } = state
      ) do
    result = OperatorTicketContext.deactivate_ticket(ticket_id)

    Logger.info(fn ->
      "#{__MODULE__} Error deactivating ticket #{ticket_id}: #{inspect(result)}"
    end)

    {:reply, result, remove_active_ticket(state, ticket_id)}
  end

  def handle_call(
        {:leave_ticket, ticket_id},
        _from,
        %{
          operator: operator
        } = state
      ) do
    result = OperatorTicketContext.operator_leaves_ticket(operator, ticket_id)

    if result == :ok do
      push_ticket_to_exchange(ticket_id)
    end

    Logger.info(fn ->
      "#{__MODULE__} Leaving operator #{operator.name} form ticket #{ticket_id} result #{
        inspect(result)
      }"
    end)

    {:reply, :ok, remove_active_ticket(state, ticket_id)}
  end

  def handle_cast(
        {:ticket_removed, ticket_id},
        %{operator: %Employer{name: name}} = state
      ) do
    Logger.info(fn ->
      "#{__MODULE__} Operator #{name} ticket removed with ID: #{ticket_id}"
    end)

    {:noreply, remove_active_ticket(state, ticket_id)}
  end

  defp remove_active_ticket(%{active_tickets: active_tickets} = state, ticket_id) do
    ticket_id = Utils.safe_to_integer(ticket_id)

    new_active_tickets =
      Enum.reject(active_tickets, fn {%Ticket{id: id}, _} -> id == ticket_id end)

    %{state | active_tickets: new_active_tickets}
  end

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

      new_state = %{
        state
        | active_tickets: [{ticket, ticket_operator}] ++ tickets,
          tickets_queue: new_tickets_queue
      }

      RabbitClient.acknowledge_message(delivery_tag)

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

        push_ticket_to_exchange(ticket_id)

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

  def handle_info(unexpected_handle_info, state) do
    Logger.error(fn ->
      "Unexpected handle info: #{inspect(unexpected_handle_info, pretty: true)}"
    end)

    {:noreply, state}
  end

  def handle_call(:get_active_tickets, _from, state) do
    {:reply, Map.get(state, :active_tickets), state}
  end

  defp check_new_tickets(check_interval \\ @check_tickets_interval) do
    Process.send_after(self(), :check_new_tickets, check_interval)
  end

  defp push_ticket_to_exchange(ticket_id) do
    Task.start(fn ->
      Process.sleep(@ticket_requeue_timeout)
      push_ticket_result = RabbitClient.push_ticket(ticket_id)

      Logger.info(fn ->
        "#{__MODULE__} Pushing ticket with ID: #{ticket_id} to queue result: #{
          inspect(push_ticket_result)
        }"
      end)
    end)
  end
end
