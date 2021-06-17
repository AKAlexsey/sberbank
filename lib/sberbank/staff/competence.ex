defmodule Sberbank.Staff.Competence do
  use Ecto.Schema
  import Ecto.Changeset

  @cast_fields [:name, :letter]
  @required_fields [:name, :letter]

  alias Sberbank.Staff.EmployerCompetence

  schema "competencies" do
    field :letter, :string
    field :name, :string

    has_many :employer_competencies, EmployerCompetence, foreign_key: :competence_id
    has_many :employers, through: [:employer_competencies, :employer]

    timestamps()
  end

  @doc false
  def changeset(competence, attrs) do
    competence
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:employer_competencies, with: &EmployerCompetence.changeset/2)
  end
end
