defmodule Sberbank.Pipeline.TicketsWorker do
  @moduledoc """
  Perform manipulations with tickets
  """

  require Logger

  use GenServer

  alias Sberbank.{Eventbus, OperatorTicketContext}
  #  alias Sberbank.Customers
  #  alias Sberbank.Customers.Ticket
  #  alias Sberbank.Staff.{Competence, Employer}
  #  alias Sberbank.Pipeline.Toolkit

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
    |> OperatorTicketContext.get_ticket_with_active_operator()
    |> case do
      {:ok, {ticket, nil}} ->
        OperatorTicketContext.deactivate_ticket(ticket)

      {:ok, {ticket, active_operator}} ->
        OperatorTicketContext.deactivate_ticket(ticket)

      {:error, reason} ->
        Logger.error(fn ->
          "#{__MODULE__} Unable to deactivate ticket #{reason}"
        end)
    end

    {:noreply, state}
  end

  def handle_info(message, state) do
    IO.puts("!!! #{__MODULE__} received message #{inspect(message, pretty: true)}")
    {:noreply, state}
  end
end
