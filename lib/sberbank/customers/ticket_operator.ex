defmodule Sberbank.Customers.TicketOperator do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ticket_operators" do
    field :active, :boolean, default: false
    field :employer_id, :id
    field :ticket_id, :id

    timestamps()
  end

  @doc false
  def changeset(ticket_operator, attrs) do
    ticket_operator
    |> cast(attrs, [:active])
    |> validate_required([:active])
  end
end
