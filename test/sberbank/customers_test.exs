defmodule Sberbank.CustomersTest do
  use Sberbank.DataCase

  alias Sberbank.Customers

  describe "customers" do
    alias Sberbank.Customers.Customer

    @valid_attrs %{email: "some email"}
    @update_attrs %{email: "some updated email"}
    @invalid_attrs %{email: nil}

    def customer_fixture(attrs \\ %{}) do
      {:ok, customer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Customers.create_customer()

      customer
    end

    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert Customers.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Customers.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      assert {:ok, %Customer{} = customer} = Customers.create_customer(@valid_attrs)
      assert customer.email == "some email"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{} = customer} = Customers.update_customer(customer, @update_attrs)
      assert customer.email == "some updated email"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_customer(customer, @invalid_attrs)
      assert customer == Customers.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Customers.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Customers.change_customer(customer)
    end
  end

  describe "tickets" do
    alias Sberbank.Customers.Ticket

    @valid_attrs %{active: true, topic: "some topic"}
    @update_attrs %{active: false, topic: "some updated topic"}
    @invalid_attrs %{active: nil, topic: nil}

    def ticket_fixture(attrs \\ %{}) do
      {:ok, ticket} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Customers.create_ticket()

      ticket
    end

    test "list_tickets/0 returns all tickets" do
      ticket = ticket_fixture()
      assert Customers.list_tickets() == [ticket]
    end

    test "get_ticket!/1 returns the ticket with given id" do
      ticket = ticket_fixture()
      assert Customers.get_ticket!(ticket.id) == ticket
    end

    test "create_ticket/1 with valid data creates a ticket" do
      assert {:ok, %Ticket{} = ticket} = Customers.create_ticket(@valid_attrs)
      assert ticket.active == true
      assert ticket.topic == "some topic"
    end

    test "create_ticket/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_ticket(@invalid_attrs)
    end

    test "update_ticket/2 with valid data updates the ticket" do
      ticket = ticket_fixture()
      assert {:ok, %Ticket{} = ticket} = Customers.update_ticket(ticket, @update_attrs)
      assert ticket.active == false
      assert ticket.topic == "some updated topic"
    end

    test "update_ticket/2 with invalid data returns error changeset" do
      ticket = ticket_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_ticket(ticket, @invalid_attrs)
      assert ticket == Customers.get_ticket!(ticket.id)
    end

    test "delete_ticket/1 deletes the ticket" do
      ticket = ticket_fixture()
      assert {:ok, %Ticket{}} = Customers.delete_ticket(ticket)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_ticket!(ticket.id) end
    end

    test "change_ticket/1 returns a ticket changeset" do
      ticket = ticket_fixture()
      assert %Ecto.Changeset{} = Customers.change_ticket(ticket)
    end
  end

  describe "ticket_operators" do
    alias Sberbank.Customers.TicketOperator

    @valid_attrs %{active: true}
    @update_attrs %{active: false}
    @invalid_attrs %{active: nil}

    def ticket_operator_fixture(attrs \\ %{}) do
      {:ok, ticket_operator} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Customers.create_ticket_operator()

      ticket_operator
    end

    test "list_ticket_operators/0 returns all ticket_operators" do
      ticket_operator = ticket_operator_fixture()
      assert Customers.list_ticket_operators() == [ticket_operator]
    end

    test "get_ticket_operator!/1 returns the ticket_operator with given id" do
      ticket_operator = ticket_operator_fixture()
      assert Customers.get_ticket_operator!(ticket_operator.id) == ticket_operator
    end

    test "create_ticket_operator/1 with valid data creates a ticket_operator" do
      assert {:ok, %TicketOperator{} = ticket_operator} = Customers.create_ticket_operator(@valid_attrs)
      assert ticket_operator.active == true
    end

    test "create_ticket_operator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_ticket_operator(@invalid_attrs)
    end

    test "update_ticket_operator/2 with valid data updates the ticket_operator" do
      ticket_operator = ticket_operator_fixture()
      assert {:ok, %TicketOperator{} = ticket_operator} = Customers.update_ticket_operator(ticket_operator, @update_attrs)
      assert ticket_operator.active == false
    end

    test "update_ticket_operator/2 with invalid data returns error changeset" do
      ticket_operator = ticket_operator_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_ticket_operator(ticket_operator, @invalid_attrs)
      assert ticket_operator == Customers.get_ticket_operator!(ticket_operator.id)
    end

    test "delete_ticket_operator/1 deletes the ticket_operator" do
      ticket_operator = ticket_operator_fixture()
      assert {:ok, %TicketOperator{}} = Customers.delete_ticket_operator(ticket_operator)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_ticket_operator!(ticket_operator.id) end
    end

    test "change_ticket_operator/1 returns a ticket_operator changeset" do
      ticket_operator = ticket_operator_fixture()
      assert %Ecto.Changeset{} = Customers.change_ticket_operator(ticket_operator)
    end
  end
end
