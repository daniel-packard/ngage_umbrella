defmodule Ngage.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :contacted, :boolean, null: false, default: false
      add :dismissed, :boolean, null: false, default: false
      add :customer_id, :integer, null: false
      add :event_definition_id, :integer, null: false

      timestamps()
    end
  end
end
