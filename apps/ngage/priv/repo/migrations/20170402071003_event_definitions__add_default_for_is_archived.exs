defmodule Ngage.Repo.Migrations.EventDefinitionsAddDefaultForIsArchived do
  use Ecto.Migration

  def change do
    alter table(:event_definitions) do
      modify :is_archived, :boolean, default: false
    end
  end
end
