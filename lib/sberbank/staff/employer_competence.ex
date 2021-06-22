defmodule Sberbank.Staff.EmployerCompetence do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @cast_fields [:competence_id, :employer_id]
  @required_fields [:competence_id, :employer_id]

  alias Sberbank.Staff.{Competence, Employer}

  schema "employer_competencies" do
    belongs_to :employer, Employer
    belongs_to :competence, Competence

    timestamps()
  end

  @doc false
  def changeset(employer_competence, attrs) do
    employer_competence
    |> cast(attrs, @cast_fields)
    |> cast_assoc(:competence, with: &Sberbank.Staff.Competence.changeset/2)
    |> cast_assoc(:employer, with: &Sberbank.Staff.Employer.changeset/2)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:competence_id, name: :employer_competencies_competence_id_fkey)
    |> foreign_key_constraint(:employer_id, name: :employer_competencies_employer_id_fkey)
  end
end
