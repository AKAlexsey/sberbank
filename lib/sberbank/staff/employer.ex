defmodule Sberbank.Staff.Employer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employers" do
    field :admin, :boolean, default: false
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(employer, attrs) do
    employer
    |> cast(attrs, [:name, :admin])
    |> validate_required([:name, :admin])
  end
end
