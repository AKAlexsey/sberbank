defmodule Sberbank.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :active, :boolean, default: false, null: false
      add :topic, :string
      add :customer_id, references(:customers, on_delete: :nothing)
      add :competence_id, references(:competencies, on_delete: :nothing)

      timestamps()
    end

    create index(:tickets, [:customer_id])
    create index(:tickets, [:competence_id])
  end
end
