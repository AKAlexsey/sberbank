defmodule Sberbank.Staff.Competence do
  use Ecto.Schema
  import Ecto.Changeset

  schema "competencies" do
    field :letter, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(competence, attrs) do
    competence
    |> cast(attrs, [:name, :letter])
    |> validate_required([:name, :letter])
  end
end
