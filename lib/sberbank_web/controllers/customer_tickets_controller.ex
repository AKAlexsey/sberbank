defmodule SberbankWeb.CustomerTicketsController do
  use SberbankWeb, :controller

  alias Sberbank.{Customers, Staff}
  alias Sberbank.Customers.Ticket
  alias Sberbank.OperatorTicketContext
  alias Sberbank.Pipeline.{OperatorClient, RabbitClient}

  def index(conn, %{"customer_id" => customer_id}) do
    %{customer: customer, tickets: tickets, competences: competences} =
      preload_necessary_data(customer_id)

    ticket_changeset = Customers.change_ticket(%Ticket{customer_id: customer.id})

    render(conn, "index.html",
      customer: customer,
      tickets: tickets,
      competences: competences,
      ticket_changeset: ticket_changeset
    )
  end

  def create(conn, %{"customer_id" => customer_id, "ticket" => ticket_params}) do
    case Customers.create_ticket(ticket_params) do
      {:ok, ticket} ->
        RabbitClient.initial_push_ticket(ticket)

        conn
        |> put_flash(:info, "Ticket created successfully")
        |> redirect(to: Routes.customer_customer_tickets_path(conn, :index, customer_id))

      {:error, %Ecto.Changeset{} = ticket_changeset} ->
        %{customer: customer, tickets: tickets, competences: competences} =
          preload_necessary_data(customer_id)

        render(conn, "new.index",
          customer: customer,
          tickets: tickets,
          competences: competences,
          ticket_changeset: ticket_changeset
        )
    end
  end

  def update(conn, %{"customer_id" => customer_id, "id" => ticket_id}) do
    ticket_id
    |> OperatorTicketContext.get_ticket_with_active_operator()
    |> case do
      {:ok, {ticket, nil}} ->
        OperatorTicketContext.deactivate_ticket(ticket)

        conn
        |> put_flash(:info, "Ticket deactivated")
        |> redirect(to: Routes.customer_customer_tickets_path(conn, :index, customer_id))

      {:ok, {ticket, active_operator}} ->
        OperatorClient.deactivate_ticket(active_operator, ticket.id)

        conn
        |> put_flash(:info, "Ticket deactivated. Operator notified")
        |> redirect(to: Routes.customer_customer_tickets_path(conn, :index, customer_id))

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.customer_customer_tickets_path(conn, :index, customer_id))
    end
  end

  def delete(conn, %{"customer_id" => customer_id, "id" => ticket_id}) do
    ticket_id
    |> OperatorTicketContext.get_ticket_with_active_operator()
    |> case do
      {:ok, {ticket, nil}} ->
        ticket
        |> Customers.delete_ticket()

        conn
        |> put_flash(:info, "Ticket deleted successfully")
        |> redirect(to: Routes.customer_customer_tickets_path(conn, :index, customer_id))

      {:ok, {ticket, active_operator}} ->
        ticket
        |> Customers.delete_ticket()

        OperatorClient.ticket_removed(active_operator, ticket.id)

        conn
        |> put_flash(:info, "Ticket deleted successfully. Operator notified")
        |> redirect(to: Routes.customer_customer_tickets_path(conn, :index, customer_id))

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.customer_customer_tickets_path(conn, :index, customer_id))
    end
  end

  defp preload_necessary_data(customer_id) do
    customer = Customers.get_customer!(customer_id, tickets: [:competence, :operators])

    %{tickets: tickets} = customer
    competences = Staff.list_competencies()

    %{customer: customer, tickets: tickets, competences: competences}
  end
end
