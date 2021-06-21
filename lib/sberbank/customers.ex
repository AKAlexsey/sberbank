defmodule Sberbank.Customers do
  @moduledoc """
  The Customers context.
  """

  import Ecto.Query, warn: false
  alias Sberbank.Repo

  alias Sberbank.Customers.Customer

  @doc """
  Returns the list of customers.

  ## Examples

      iex> list_customers()
      [%Customer{}, ...]

  """
  def list_customers do
    Repo.all(Customer)
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer!(id, preload \\ []) do
    Customer
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  @doc """
  Creates a customer.

  ## Examples

      iex> create_customer(%{field: value})
      {:ok, %Customer{}}

      iex> create_customer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_customer(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{data: %Customer{}}

  """
  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  alias Sberbank.Customers.Ticket

  @doc """
  Returns the list of tickets.

  ## Examples

      iex> list_tickets()
      [%Ticket{}, ...]

  """
  def list_tickets do
    Repo.all(Ticket)
  end

  @doc """
  Gets a single ticket.

  Raises `Ecto.NoResultsError` if the Ticket does not exist.

  ## Examples

      iex> get_ticket!(123)
      %Ticket{}

      iex> get_ticket!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticket!(id, preload \\ []) do
    Ticket
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  @doc """
  Creates a ticket.

  ## Examples

      iex> create_ticket(%{field: value})
      {:ok, %Ticket{}}

      iex> create_ticket(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket(attrs \\ %{}) do
    %Ticket{}
    |> Ticket.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket.

  ## Examples

      iex> update_ticket(ticket, %{field: new_value})
      {:ok, %Ticket{}}

      iex> update_ticket(ticket, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket(%Ticket{} = ticket, attrs) do
    ticket
    |> Ticket.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ticket.

  ## Examples

      iex> delete_ticket(ticket)
      {:ok, %Ticket{}}

      iex> delete_ticket(ticket)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket(%Ticket{} = ticket) do
    Repo.delete(ticket)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket changes.

  ## Examples

      iex> change_ticket(ticket)
      %Ecto.Changeset{data: %Ticket{}}

  """
  def change_ticket(%Ticket{} = ticket, attrs \\ %{}) do
    Ticket.changeset(ticket, attrs)
  end

  alias Sberbank.Customers.TicketOperator

  @doc """
  Returns the list of ticket_operators.

  ## Examples

      iex> list_ticket_operators()
      [%TicketOperator{}, ...]

  """
  def list_ticket_operators do
    Repo.all(TicketOperator)
  end

  @doc """
  Gets a single ticket_operator.

  Raises `Ecto.NoResultsError` if the Ticket operator does not exist.

  ## Examples

      iex> get_ticket_operator!(123)
      %TicketOperator{}

      iex> get_ticket_operator!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticket_operator!(id), do: Repo.get!(TicketOperator, id)

  @doc """
  Creates a ticket_operator.

  ## Examples

      iex> create_ticket_operator(%{field: value})
      {:ok, %TicketOperator{}}

      iex> create_ticket_operator(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket_operator(attrs \\ %{}) do
    %TicketOperator{}
    |> TicketOperator.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket_operator.

  ## Examples

      iex> update_ticket_operator(ticket_operator, %{field: new_value})
      {:ok, %TicketOperator{}}

      iex> update_ticket_operator(ticket_operator, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket_operator(%TicketOperator{} = ticket_operator, attrs) do
    ticket_operator
    |> TicketOperator.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ticket_operator.

  ## Examples

      iex> delete_ticket_operator(ticket_operator)
      {:ok, %TicketOperator{}}

      iex> delete_ticket_operator(ticket_operator)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket_operator(%TicketOperator{} = ticket_operator) do
    Repo.delete(ticket_operator)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket_operator changes.

  ## Examples

      iex> change_ticket_operator(ticket_operator)
      %Ecto.Changeset{data: %TicketOperator{}}

  """
  def change_ticket_operator(%TicketOperator{} = ticket_operator, attrs \\ %{}) do
    TicketOperator.changeset(ticket_operator, attrs)
  end
end
