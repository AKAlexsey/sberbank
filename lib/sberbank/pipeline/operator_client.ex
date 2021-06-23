defmodule Sberbank.Pipeline.OperatorClient do
  @moduledoc """
  Represent behaviour of Operator client. Should be responsible for the connection
  of one operator
  """

  use GenServer

  require Logger

  @max_tickets 3
  @check_tickets_interval 500

  alias Sberbank.Customers.{Ticket, TicketOperator}
  alias Sberbank.{OperatorTicketContext, Staff}
  alias Sberbank.Staff.Employer
  alias Sberbank.Pipeline.{RabbitClient, Toolkit}

  def push_ticket(%Ticket{} = ticket) do
    GenServer.cast(__MODULE__, {:push_ticket, ticket})
  end

  @spec get_active_tickets(Employer.t) :: list(map)
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
    check_new_tickets(2000)
    {:ok, %{operator: operator, active: true, active_tickets: [], tickets_queue: :queue.new()}}
  end

  def handle_info({:basic_deliver, encoded_data, metadata}, %{tickets_queue: tickets_queue} = state) do
    Jason.decode(encoded_data)
    |> case do
      {:ok, ticket_data} ->
        new_tickets_queue = :queue.in({ticket_data, metadata}, tickets_queue)
        {:noreply, %{state | tickets_queue: new_tickets_queue}}
      {:error, reason} ->
        Logger.error(fn -> "Error parsing data for #{inspect(self())}: #{reason}" end)
        {:noreply, state}
       end
  end

  def handle_info({:basic_consume_ok, _}, state) do
    {:noreply, state}
  end

  def handle_info(:check_new_tickets, %{active: true, active_tickets: tickets, operator: operator, tickets_queue: tickets_queue} = state) when length(tickets) < @max_tickets do
    IO.puts("!!! check_new_tickets")
    with {{:value, {%{"id" => ticket_id}, ticket_meta}}, new_tickets_queue} <- :queue.out(tickets_queue),
         {:ok, {ticket, ticket_operator}} <- OperatorTicketContext.add_operator_to_ticket(ticket_id, operator) do
      check_new_tickets()
      {:noreply, %{state | tickets: [{ticket, ticket_operator}] ++ tickets, tickets_queue: new_tickets_queue}}
    else
      {:error, reason} when is_binary(reason)->
        check_new_tickets()
        Logger.info(fn -> "#{__MODULE__} Error linking operator to ticket: #{reason}" end)
        {:noreply, state}
      {:empty, _} ->
        check_new_tickets()
        {:noreply, state}
    end
  end

  def handle_info(unexpected_handle_info, state) do
    Logger.error(fn -> "Unexpected handle info: #{inspect(unexpected_handle_info, pretty: true)}" end)
    {:noreply, state}
  end

  def handle_call(:get_active_tickets, _from, state) do
    {:reply, Map.get(state, :active_tickets), state}
  end

  defp check_new_tickets(check_interval \\ @check_tickets_interval) do
    Process.send_after(self(), :check_new_tickets, check_interval)
  end
end
