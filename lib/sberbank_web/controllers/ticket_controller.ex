defmodule SberbankWeb.TicketController do
  use SberbankWeb, :controller

  alias Sberbank.Customers
  alias Sberbank.Customers.Ticket

  def index(conn, _params) do
    tickets = Customers.list_tickets()
    render(conn, "index.html", tickets: tickets)
  end

  def new(conn, _params) do
    changeset = Customers.change_ticket(%Ticket{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"ticket" => ticket_params}) do
    case Customers.create_ticket(ticket_params) do
      {:ok, ticket} ->
        conn
        |> put_flash(:info, "Ticket created successfully.")
        |> redirect(to: Routes.ticket_path(conn, :show, ticket))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ticket = Customers.get_ticket!(id)
    render(conn, "show.html", ticket: ticket)
  end

  def edit(conn, %{"id" => id}) do
    ticket = Customers.get_ticket!(id)
    changeset = Customers.change_ticket(ticket)
    render(conn, "edit.html", ticket: ticket, changeset: changeset)
  end

  def update(conn, %{"id" => id, "ticket" => ticket_params}) do
    ticket = Customers.get_ticket!(id)

    case Customers.update_ticket(ticket, ticket_params) do
      {:ok, ticket} ->
        conn
        |> put_flash(:info, "Ticket updated successfully.")
        |> redirect(to: Routes.ticket_path(conn, :show, ticket))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", ticket: ticket, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ticket = Customers.get_ticket!(id)
    {:ok, _ticket} = Customers.delete_ticket(ticket)

    conn
    |> put_flash(:info, "Ticket deleted successfully.")
    |> redirect(to: Routes.ticket_path(conn, :index))
  end
end
