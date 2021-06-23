defmodule Sberbank.OperatorTicketContext do
  @moduledoc """
  Contains functions that allows to add operators to ticket, change ticket operator.
  """

  alias Sberbank.Customers
  alias Sberbank.Customers.{Ticket, TicketOperator}
  alias Sberbank.Staff.Employer

  @doc """
  Check if ticket already has TicketOperator with active = true for operator other than given.
  If yes - return {:error, "Ticket already has operator}
  If no - create TicketOperator with appropriate links and active = true
  Perform all manipulations in Ecto transaction
  """
  @spec add_operator_to_ticket(binary, Employer.t()) ::
          {:ok, {Ticket.t(), TicketOperator.t()}} | {:error, binary}
  def add_operator_to_ticket(ticket_id, %Employer{id: operator_id}) do
    IO.puts("!!! add_oeprator to ticket #{ticket_id}")
    with ticket when not is_nil(ticket) <- Customers.get_ticket(ticket_id, [:operators]),
         {:ok, ticket_operator} <-
           Customers.create_ticket_operator(%{
             ticket_id: ticket.id,
             employer_id: operator_id,
             active: true
           }) do
      {:ok, {ticket, ticket_operator}}
    else
      {:error, reason} ->
        {:error, inspect(reason, pretty: true)}
      _ ->
        {:error, "No ticket with id: #{ticket_id}"}
    end
  end
end
