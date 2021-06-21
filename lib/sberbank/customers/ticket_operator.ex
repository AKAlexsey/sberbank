defmodule Sberbank.Customers.TicketOperator do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sberbank.Customers.Ticket
  alias Sberbank.Staff.Employer

  @cast_fields [:active, :employer_id, :ticket_id]
  @required_fields [:active, :employer_id, :ticket_id]

  @type t :: %__MODULE__{}

  schema "ticket_operators" do
    field :active, :boolean, default: true

    belongs_to :employer, Employer
    belongs_to :ticket, Ticket

    timestamps()
  end

  @doc false
  def changeset(ticket_operator, attrs) do
    ticket_operator
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
