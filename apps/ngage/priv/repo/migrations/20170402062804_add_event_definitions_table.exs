defmodule Ngage.Repo.Migrations.AddEventDefinitionsTable do
  use Ecto.Migration

  def change do
    create table(:event_definitions) do
      add :description, :string, size: 256
      add :is_archived, :boolean
    end
  end
end
