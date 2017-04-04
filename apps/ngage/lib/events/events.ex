
defmodule Ngage.Events do
    use Ecto.Schema
    
    import Ecto.Changeset

    schema "events" do
        belongs_to :customer, Ngage.Customers
        belongs_to :event_definition, Ngage.EventDefinitions
        field :contacted, :boolean, null: false, default: false
        field :dismissed, :boolean, null: false, default: false

        timestamps()
    end

    def changeset(event, params \\ %{}) do
        event
    end
end