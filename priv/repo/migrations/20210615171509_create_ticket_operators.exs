defmodule Sberbank.Repo.Migrations.CreateTicketOperators do
  use Ecto.Migration

  def change do
    create table(:ticket_operators) do
      add :active, :boolean, default: true, null: false
      add :employer_id, references(:employers, on_delete: :delete_all)
      add :ticket_id, references(:tickets, on_delete: :delete_all)

      timestamps()
    end

    create index(:ticket_operators, [:employer_id])
    create index(:ticket_operators, [:ticket_id])
    create unique_index(:ticket_operators, [:employer_id, :ticket_id])
  end
end
