defmodule Sberbank.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sberbank.Customers.Ticket

  @cast_fields [:email]
  @required_fields [:email]

  @type t :: %__MODULE__{}

  schema "customers" do
    field :email, :string

    has_many :tickets, Ticket

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
