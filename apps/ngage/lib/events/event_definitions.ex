defmodule Ngage.EventDefinitions do
    use Ecto.Schema
    
    import Ecto.Changeset

    schema "event_definitions" do
        field :description, :string
        field :is_archived, :boolean
    end

    @required_fields ~w(description)a
    @optional_fields ~w(is_archived)a

    def changeset(event_definition, params \\ %{}) do
        event_definition
        |> cast(params, @required_fields ++ @optional_fields)
        |> validate_required(@required_fields)
    end
end
