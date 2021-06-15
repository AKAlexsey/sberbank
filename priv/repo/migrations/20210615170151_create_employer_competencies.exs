defmodule Sberbank.Repo.Migrations.CreateEmployerCompetencies do
  use Ecto.Migration

  def change do
    create table(:employer_competencies) do
      add :employer_id, references(:employers, on_delete: :delete_all)
      add :competence_id, references(:competencies, on_delete: :delete_all)

      timestamps()
    end

    create index(:employer_competencies, [:employer_id])
    create index(:employer_competencies, [:competence_id])
    create unique_index(:employer_competencies, [:employer_id, :competence_id])
  end
end
