defmodule Sberbank.Repo.Migrations.CreateEmployers do
  use Ecto.Migration

  def change do
    create table(:employers) do
      add :name, :string
      add :admin, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:employers, [:name])
  end
end
