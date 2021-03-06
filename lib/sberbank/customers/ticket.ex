defmodule Sberbank.Customers.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sberbank.Customers.{Customer, TicketOperator}
  alias Sberbank.Staff.Competence

  @type t :: %__MODULE__{}

  @cast_fields [:active, :topic, :customer_id, :competence_id]
  @required_fields [:active, :topic, :customer_id, :competence_id]

  schema "tickets" do
    field :active, :boolean, default: true
    field :topic, :string

    belongs_to :competence, Competence
    belongs_to :customer, Customer

    has_many :ticket_operators, TicketOperator
    has_many :operators, through: [:ticket_operators, :employer]

    timestamps()
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
