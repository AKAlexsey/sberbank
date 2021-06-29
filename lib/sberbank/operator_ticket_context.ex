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

  @ticket_reroute_timeout_seconds 5

  @doc """
  Check if ticket already has TicketOperator with active = true for operator other than given.
  If yes - return {:error, "Ticket already has operator}
  If no - create TicketOperator with appropriate links and active = true
  Perform all manipulations in Ecto transaction
  """
  @spec add_operator_to_ticket(binary, Employer.t()) ::
          {:ok, {Ticket.t(), TicketOperator.t()}} | {:error, binary} | {:error, :try_later}
  def add_operator_to_ticket(ticket_id, %Employer{id: operator_id}) do
    with ticket when not is_nil(ticket) <-
           Customers.get_ticket(ticket_id, [:operators, :competence]),
         :ok <- operator_did_not_left_ticket_recently?(ticket, operator_id),
         {:ok, ticket_operator} <-
           Customers.create_ticket_operator(%{
             ticket_id: ticket.id,
             employer_id: operator_id,
             active: true
           }) do
      {:ok, {ticket, ticket_operator}}
    else
      {:error, %Ecto.Changeset{} = error_changeset} ->
        serialized_errors =
          error_changeset
          |> Utils.traverse_errors()
          |> Enum.map(fn {key, errors} -> "#{key}: #{Enum.join(errors, " ")}" end)
          |> Enum.join("\n")

        {:error, serialized_errors}

      {:error, reason} when is_binary(reason) ->
        {:error, reason}

      _ ->
        {:error, "No ticket with id: #{ticket_id}"}
    end
  end

  @spec operator_did_not_left_ticket_recently?(Ticket.t(), integer | binary) ::
          :ok | {:error, :try_later}
  defp operator_did_not_left_ticket_recently?(
         %Ticket{ticket_operators: ticket_operators},
         checked_operator_id
       ) do
    now = NaiveDateTime.utc_now()

    ticket_operators
    |> Enum.any?(fn %TicketOperator{
                      employer_id: operator_id,
                      active: active,
                      updated_at: updated_at
                    } ->
      operator_id == checked_operator_id && active == false &&
        NaiveDateTime.diff(now, updated_at) < @ticket_reroute_timeout_seconds
    end)
    |> case do
      false ->
        :ok

      true ->
        {:error, :try_later}
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
    |> Repo.preload([ticket: :competence])
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

  # TODO will be legacy after adding pubsub
  @spec get_ticket_with_active_operator(integer | binary) ::
          {:ok, {Ticket.t(), Employer.t() | nil}} | {:error, binary}
  def get_ticket_with_active_operator(ticket_id) do
    with ticket when not is_nil(ticket) <-
           Customers.get_ticket(ticket_id, ticket_operators: :employer),
         active_operator <-
           select_active_ticket_operator(ticket) do
      {:ok, {ticket, active_operator}}
    else
      nil ->
        {:error, "Ticket with id: #{ticket_id} not found"}

      unexpected_reason ->
        {:error, inspect(unexpected_reason)}
    end
  end

  defp select_active_ticket_operator(%{ticket_operators: ticket_operators}) do
    ticket_operators
    |> Enum.find(& &1.active)
    |> case do
      nil -> nil
      %{employer: employer} -> employer
    end
  end

  @spec deactivate_ticket(integer | binary | Ticket.t()) :: {:ok, Ticket.t()} | {:error, binary}
  def deactivate_ticket(%Ticket{ticket_operators: ticket_operators} = ticket)
      when is_list(ticket_operators) do
    Repo.transaction(fn ->
      try do
        {:ok, updated_ticket} = Customers.update_ticket(ticket, %{active: false})

        ticket_operators
        |> Enum.each(fn
          %{active: true} = ticket_operator ->
            {:ok, _} = Customers.update_ticket_operator(ticket_operator, %{active: false})

          _ ->
            :ok
        end)

        updated_ticket
      rescue
        e ->
          {:error, Exception.message(e)}
      end
    end)
    |> case do
      {:ok, {:error, reason}} ->
        {:error, reason}

      {:ok, %Ticket{} = ticket} ->
        {:ok, ticket}
    end
  end

  def deactivate_ticket(%Ticket{id: ticket_id}) do
    deactivate_ticket(ticket_id)
  end

  def deactivate_ticket(ticket_id) do
    ticket_id
    |> Customers.get_ticket([:operators])
    |> case do
      nil ->
        {:error, "Ticket with id: #{ticket_id} not found"}

      ticket ->
        deactivate_ticket(ticket)
    end
  end
end
