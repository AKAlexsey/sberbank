defmodule Sberbank.OperatorTicketContextTest do
  use Sberbank.DataCase

  alias Sberbank.{Customers, OperatorTicketContext, Staff}
  alias Sberbank.Customers.{Ticket, TicketOperator}

  @employer_default_attrs %{admin: true, name: "ExampleOperator"}
  @customer_default_attrs %{admin: true, email: "angry.hourwife@gmail.com"}
  @competence_valid_attrs %{letter: "C", name: "Credit"}
  @ticket_default_attrs %{active: true}
  @ticket_operator_default_attrs %{active: true}

  def employer_fixture(attrs \\ %{}) do
    {:ok, employer} =
      attrs
      |> Enum.into(@employer_default_attrs)
      |> Staff.create_employer()

    employer
  end

  def customer_fixture(attrs \\ %{}) do
    {:ok, customer} =
      attrs
      |> Enum.into(@customer_default_attrs)
      |> Customers.create_customer()

    customer
  end

  def competence_fixture(attrs \\ %{}) do
    {:ok, competence} =
      attrs
      |> Enum.into(@competence_valid_attrs)
      |> Staff.create_competence()

    competence
  end

  def ticket_operator_fixture(attrs \\ %{}) do
    {:ok, ticket_operator} =
      attrs
      |> Enum.into(@ticket_operator_default_attrs)
      |> Customers.create_ticket_operator()

    ticket_operator
  end

  def ticket_fixture(attrs \\ %{}) do
    {:ok, ticket} =
      attrs
      |> Enum.into(@ticket_default_attrs)
      |> Customers.create_ticket()

    ticket
  end

  describe "#get_operator_active_tickets" do
    setup do
      customer = customer_fixture()
      competence = competence_fixture()
      operator_1 = employer_fixture(%{name: "ExperiencedOperator"})
      operator_2 = employer_fixture(%{name: "NewbieOperator"})

      ticket_1 =
        ticket_fixture(%{
          customer_id: customer.id,
          active: true,
          topic: "Can't pay credit",
          competence_id: competence.id
        })

      ticket_2 =
        ticket_fixture(%{
          customer_id: customer.id,
          active: true,
          topic: "Open credit cart",
          competence_id: competence.id
        })

      {
        :ok,
        customer: customer,
        competence: competence,
        operator_1: operator_1,
        operator_2: operator_2,
        ticket_1: ticket_1,
        ticket_2: ticket_2
      }
    end

    test "Return all OperatorTickets only with {active: true}", %{
      operator_1: operator_1,
      operator_2: operator_2,
      ticket_1: %{id: ticket_1_id},
      ticket_2: %{id: ticket_2_id}
    } do
      ticket_operator_fixture(%{
        ticket_id: ticket_1_id,
        employer_id: operator_2.id,
        active: false
      })

      %{id: first_active_ticket_operator_id} =
        ticket_operator_fixture(%{
          ticket_id: ticket_1_id,
          employer_id: operator_1.id,
          active: true
        })

      ticket_operator_fixture(%{
        ticket_id: ticket_2_id,
        employer_id: operator_2.id,
        active: false
      })

      ticket_operator_fixture(%{
        ticket_id: ticket_2_id,
        employer_id: operator_1.id,
        active: false
      })

      %{id: second_active_ticket_operator_id} =
        ticket_operator_fixture(%{
          ticket_id: ticket_2_id,
          employer_id: operator_1.id,
          active: true
        })

      assert [
               {%{id: ^ticket_1_id}, %{id: ^first_active_ticket_operator_id}},
               {%{id: ^ticket_2_id}, %{id: ^second_active_ticket_operator_id}}
             ] = OperatorTicketContext.get_operator_active_tickets(operator_1)
    end

    test "Return empty list if there are no active ticket_operators", %{
      operator_1: operator_1,
      operator_2: operator_2,
      ticket_1: %{id: ticket_1_id},
      ticket_2: %{id: ticket_2_id}
    } do
      ticket_operator_fixture(%{
        ticket_id: ticket_1_id,
        employer_id: operator_2.id,
        active: false
      })

      ticket_operator_fixture(%{
        ticket_id: ticket_2_id,
        employer_id: operator_2.id,
        active: false
      })

      ticket_operator_fixture(%{
        ticket_id: ticket_2_id,
        employer_id: operator_1.id,
        active: false
      })

      assert [] == OperatorTicketContext.get_operator_active_tickets(operator_1)
    end
  end

  describe "#add_operator_to_ticket" do
    setup do
      customer = customer_fixture()
      competence = competence_fixture()
      operator_1 = employer_fixture(%{name: "ExperiencedOperator"})
      operator_2 = employer_fixture(%{name: "NewbieOperator"})

      ticket =
        ticket_fixture(%{
          customer_id: customer.id,
          active: true,
          topic: "Can't pay credit",
          competence_id: competence.id
        })

      {
        :ok,
        customer: customer,
        competence: competence,
        operator_1: operator_1,
        operator_2: operator_2,
        ticket: ticket
      }
    end

    test "Create ticket operator if everything is alright", %{
      operator_1: operator_1,
      operator_2: operator_2,
      ticket: %{id: ticket_id}
    } do
      ticket_operator_fixture(%{
        ticket_id: ticket_id,
        employer_id: operator_2.id,
        active: false
      })

      assert {:ok,
              {%Ticket{id: ^ticket_id}, %TicketOperator{active: true, ticket_id: ^ticket_id}}} =
               OperatorTicketContext.add_operator_to_ticket(ticket_id, operator_1)
    end

    test "Return error if ticket already have active TicketOperator relation", %{
      operator_1: operator_1,
      operator_2: operator_2,
      ticket: %{id: ticket_id}
    } do
      ticket_operator_fixture(%{
        ticket_id: ticket_id,
        employer_id: operator_2.id,
        active: true
      })

      assert {:error,
              "ticket_id: Only one active OperatorTicket allowed for Ticket simultaneously"} =
               OperatorTicketContext.add_operator_to_ticket(ticket_id, operator_1)
    end

    test "Return error if ticket with given ID does not exist", %{operator_1: operator} do
      non_existing_ticket_id = 777_777

      assert {:error, "No ticket with id: #{non_existing_ticket_id}"} ==
               OperatorTicketContext.add_operator_to_ticket(non_existing_ticket_id, operator)
    end
  end
end
