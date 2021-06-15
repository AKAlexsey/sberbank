defmodule Sberbank.Repo.Migrations.CreateCompetencies do
  use Ecto.Migration

  def change do
    create table(:competencies) do
      add :name, :string
      add :letter, :string

      timestamps()
    end

    create unique_index(:competencies, [:name])
    create unique_index(:competencies, [:letter])
  end
end
