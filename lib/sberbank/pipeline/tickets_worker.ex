defmodule Sberbank.Pipeline.TicketsWorker do
  @moduledoc """
  Perform manipulations with tickets
  """

  @ticket_requeue_timeout 1000

  require Logger

  use GenServer

  alias Sberbank.{Customers, Eventbus, OperatorTicketContext}
  alias Sberbank.Pipeline.RabbitClient

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Eventbus.subscribe_tickets()

    {:ok, %{}}
  end

  def handle_info({:ticket_deleted, _}, state) do
    {:noreply, state}
  end

  def handle_info({:ticket_deactivated, ticket}, state) do
    ticket.id
    |> Customers.get_ticket()
    |> case do
      nil ->
        Logger.error(fn ->
          "#{__MODULE__} Ticket with #{ticket.id} not found"
        end)

      ticket ->
        OperatorTicketContext.deactivate_ticket(ticket)
    end

    {:noreply, state}
  end

  def handle_info({:operator_leaves_ticket, operator, ticket_id}, state) do
    result = OperatorTicketContext.operator_leaves_ticket(operator, ticket_id)

    Eventbus.broadcast_repeat_push_ticket(ticket_id)

    Logger.info(fn ->
      "#{__MODULE__} Leaving operator #{operator.name} form ticket #{ticket_id} result #{inspect(result)}"
    end)

    {:noreply, state}
  end

  def handle_info({:initial_push_ticket, ticket}, state) do
    push_ticket_result = RabbitClient.initial_push_ticket(ticket)

    Logger.info(fn ->
      "#{__MODULE__} Initial pushing ticket with ID: #{ticket.id} to queue result: #{inspect(push_ticket_result)}"
    end)

    {:noreply, state}
  end

  def handle_info({:repeat_push_ticket, ticket_id}, state) do
    Process.sleep(@ticket_requeue_timeout)
    push_ticket_result = RabbitClient.repeat_push_ticket(ticket_id)

    Logger.info(fn ->
      "#{__MODULE__} Repeat pushing ticket with ID: #{ticket_id} to queue result: #{inspect(push_ticket_result)}"
    end)

    {:noreply, state}
  end

  def handle_info(message, state) do
    Logger.warning(fn ->
      "#{__MODULE__} Unexpected message: #{inspect(message, pretty: true)}"
    end)

    {:noreply, state}
  end
end
