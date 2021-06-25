defmodule Sberbank.OperatorTicketContext do
  @moduledoc """
  Contains functions that allows to add operators to ticket, change ticket operator.
  """

  import Ecto.Query

  alias Sberbank.Customers
  alias Sberbank.Customers.{Ticket, TicketOperator}
  alias Sberbank.Repo
  alias Sberbank.Staff.Employer
  alias Sberbank.Utils

  @doc """
  Check if ticket already has TicketOperator with active = true for operator other than given.
  If yes - return {:error, "Ticket already has operator}
  If no - create TicketOperator with appropriate links and active = true
  Perform all manipulations in Ecto transaction
  """
  @spec add_operator_to_ticket(binary, Employer.t()) ::
          {:ok, {Ticket.t(), TicketOperator.t()}} | {:error, binary}
  def add_operator_to_ticket(ticket_id, %Employer{id: operator_id}) do
    with ticket when not is_nil(ticket) <- Customers.get_ticket(ticket_id, [:operators]),
         {:ok, ticket_operator} <-
           Customers.create_ticket_operator(%{
             ticket_id: ticket.id,
             employer_id: operator_id,
             active: true
           }) do
      {:ok, {ticket, ticket_operator}}
    else
      {:error, error_changeset} ->
        serialized_errors =
          error_changeset
          |> Utils.traverse_errors()
          |> Enum.map(fn {key, errors} -> "#{key}: #{Enum.join(errors, " ")}" end)
          |> Enum.join("\n")

        {:error, serialized_errors}

      _ ->
        {:error, "No ticket with id: #{ticket_id}"}
    end
  end

  @spec get_operator_active_tickets(Employer.t()) ::
          {:ok, list({Ticket.t(), TicketOperator.t()})} | {:error, binary}
  def get_operator_active_tickets(%Employer{id: operator_id}) do
    from(to in TicketOperator,
      where: [employer_id: ^operator_id, active: true],
      preload: [:ticket],
      order_by: [:id]
    )
    |> Repo.all()
    |> Enum.map(fn %TicketOperator{ticket: ticket} = ticket_operator ->
      {ticket, ticket_operator}
    end)
  end

  @spec operator_leaves_ticket(Employer.t(), integer) :: :ok | {:error, binary}
  def operator_leaves_ticket(%Employer{id: operator_id}, ticket_id) do
    with ticket_operator when not is_nil(ticket_operator) <-
           Repo.get_by(TicketOperator,
             employer_id: operator_id,
             ticket_id: ticket_id,
             active: true
           ),
         {:ok, %TicketOperator{}} <-
           Customers.update_ticket_operator(ticket_operator, %{active: false}) do
      :ok
    else
      nil ->
        {:error,
         "Active OperatorTicket for employer_id: #{operator_id}, ticket_id: #{ticket_id} not found"}

      unexpected_reason ->
        {:error, inspect(unexpected_reason)}
    end
  end
end
