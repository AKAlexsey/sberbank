defmodule Sberbank.Customers.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

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
    |> cast(attrs, [:active, :topic])
    |> validate_required([:active, :topic])
  end
end
