defmodule Ngage.Repo.Migrations.EventDefinitionsMakeDescriptionNonNullable do
  use Ecto.Migration

  def change do
    alter table(:event_definitions) do
      modify :description, :string, size: 256, null: false
    end
  end
end
