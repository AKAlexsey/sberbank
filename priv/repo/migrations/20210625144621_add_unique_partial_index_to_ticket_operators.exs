defmodule Sberbank.Repo.Migrations.AddUniquePartialIndexToTicketOperators do
  use Ecto.Migration

  def change do
    create unique_index(:ticket_operators, [:ticket_id, :active], where: "ACTIVE = TRUE")
    drop_if_exists unique_index(:ticket_operators, [:employer_id, :ticket_id])
  end
end
