defmodule Sberbank.Staff.EmployerCompetence do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employer_competencies" do
    field :employer_id, :id
    field :competence_id, :id

    timestamps()
  end

  @doc false
  def changeset(employer_competence, attrs) do
    employer_competence
    |> cast(attrs, [])
    |> validate_required([])
  end
end
