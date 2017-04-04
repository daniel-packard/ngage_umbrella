defmodule Ngage.Repo.Migrations.AddCustomersTable do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :username, :string, size: 256, null: false
    end
  end
end
