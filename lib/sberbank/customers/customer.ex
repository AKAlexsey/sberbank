defmodule Sberbank.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "customers" do
    field :email, :string

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end
end
