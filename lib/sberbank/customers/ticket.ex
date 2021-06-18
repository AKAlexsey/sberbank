defmodule Sberbank.Customers.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  @cast_fields [:active, :topic, :customer_id, :competence_id]
  @required_fields [:active, :topic, :customer_id, :competence_id]

  schema "tickets" do
    field :active, :boolean, default: false
    field :topic, :string
    field :customer_id, :id
    field :competence_id, :id

    timestamps()
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
