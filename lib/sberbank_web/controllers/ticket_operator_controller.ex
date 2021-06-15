defmodule SberbankWeb.TicketOperatorController do
  use SberbankWeb, :controller

  alias Sberbank.Customers
  alias Sberbank.Customers.TicketOperator

  def index(conn, _params) do
    ticket_operators = Customers.list_ticket_operators()
    render(conn, "index.html", ticket_operators: ticket_operators)
  end

  def new(conn, _params) do
    changeset = Customers.change_ticket_operator(%TicketOperator{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"ticket_operator" => ticket_operator_params}) do
    case Customers.create_ticket_operator(ticket_operator_params) do
      {:ok, ticket_operator} ->
        conn
        |> put_flash(:info, "Ticket operator created successfully.")
        |> redirect(to: Routes.ticket_operator_path(conn, :show, ticket_operator))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ticket_operator = Customers.get_ticket_operator!(id)
    render(conn, "show.html", ticket_operator: ticket_operator)
  end

  def edit(conn, %{"id" => id}) do
    ticket_operator = Customers.get_ticket_operator!(id)
    changeset = Customers.change_ticket_operator(ticket_operator)
    render(conn, "edit.html", ticket_operator: ticket_operator, changeset: changeset)
  end

  def update(conn, %{"id" => id, "ticket_operator" => ticket_operator_params}) do
    ticket_operator = Customers.get_ticket_operator!(id)

    case Customers.update_ticket_operator(ticket_operator, ticket_operator_params) do
      {:ok, ticket_operator} ->
        conn
        |> put_flash(:info, "Ticket operator updated successfully.")
        |> redirect(to: Routes.ticket_operator_path(conn, :show, ticket_operator))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", ticket_operator: ticket_operator, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ticket_operator = Customers.get_ticket_operator!(id)
    {:ok, _ticket_operator} = Customers.delete_ticket_operator(ticket_operator)

    conn
    |> put_flash(:info, "Ticket operator deleted successfully.")
    |> redirect(to: Routes.ticket_operator_path(conn, :index))
  end
end
