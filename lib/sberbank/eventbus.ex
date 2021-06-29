defmodule Sberbank.Eventbus do
  @moduledoc """
  Represent common eventbus that allows to bradcast messages to the whole system
  It allows to clean up the code, remove useless operations.
  All subscribers will receive necessary message.
  The place where any event happens - does not need to perform any additional actions, live finding subscribers.
  """

  alias Sberbank.Customers
  alias Sberbank.Customers.Ticket
  alias Sberbank.Staff.{Competence, Employer}

  @pubsub_server Sberbank.PubSub
  @exchanges_bus "exchanges"
  @tickets_bus "tickets"

  # Common API
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(@pubsub_server, topic)
  end

  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(@pubsub_server, topic, message)
  end

  # Exchanges API
  def subscribe_exchanges do
    subscribe(@exchanges_bus)
  end

  def broadcast_exchanges(message) do
    broadcast(@exchanges_bus, message)
  end

  def broadcast_competence_updated(%Competence{} = old_competence, %Competence{} = new_competence) do
    broadcast_exchanges({:competence_updated, old_competence, new_competence})
  end

  def broadcast_competence_deleted(%Competence{} = competence) do
    broadcast_exchanges({:competence_deleted, competence})
  end

  # Employer API
  def subscribe_operator(%Employer{} = operator) do
    operator
    |> operator_topic()
    |> subscribe()
  end

  def broadcast_operator_updated(%Employer{} = operator) do
    operator
    |> operator_topic()
    |> broadcast(:operator_updated)
  end

  def broadcast_operator_tickets_updated(operator, active_tickets) do
    operator
    |> operator_topic()
    |> broadcast({:operator_tickets_updated, active_tickets})
  end

  defp operator_topic(%Employer{id: id}), do: "operator:#{id}"

  # Tickets API
  def subscribe_tickets do
    subscribe(@tickets_bus)
  end

  def broadcast_tickets(message) do
    broadcast(@tickets_bus, message)
  end

  def broadcast_ticket_deactivated(%Ticket{} = ticket) do
    broadcast_tickets({:ticket_deactivated, ticket})
  end

  def broadcast_ticket_deactivated(ticket_id) do
    ticket_id
    |> Customers.get_ticket()
    |> broadcast_ticket_deactivated()
  end

  def broadcast_ticket_deleted(%Ticket{} = ticket) do
    broadcast_tickets({:ticket_deleted, ticket})
  end

  def broadcast_operator_leaves_ticket(%Employer{} = operator, ticket_id) do
    broadcast_tickets({:operator_leaves_ticket, operator, ticket_id})
  end

  def broadcast_initial_push_ticket(%Ticket{} = ticket) do
    broadcast_tickets({:initial_push_ticket, ticket})
  end

  def broadcast_initial_push_ticket(ticket_id) do
    ticket_id
    |> Customers.get_ticket()
    |> broadcast_initial_push_ticket()
  end

  def broadcast_repeat_push_ticket(ticket_id) do
    broadcast_tickets({:repeat_push_ticket, ticket_id})
  end
end
