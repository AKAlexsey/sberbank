defmodule Sberbank.Staff.Employer do
  use Ecto.Schema
  import Ecto.Changeset

  @cast_fields [:admin, :name]
  @required_fields [:admin, :name]

  alias Sberbank.Staff.EmployerCompetence

  schema "employers" do
    field :admin, :boolean, default: false
    field :name, :string

    has_many :employer_competencies, EmployerCompetence,
      foreign_key: :employer_id,
      on_replace: :delete

    has_many :competencies, through: [:employer_competencies, :competence]

    timestamps()
  end

  @doc false
  def changeset(employer, attrs) do
    employer
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:employer_competencies, with: &EmployerCompetence.changeset/2)
  end
end
