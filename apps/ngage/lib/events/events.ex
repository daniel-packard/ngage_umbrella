
defmodule Ngage.Events do
    use Ecto.Schema
    
    import Ecto.Changeset

    @derive {Poison.Encoder, except: [:__meta__, :customer]}
    schema "events" do
        belongs_to :customer, Ngage.Customers
        belongs_to :event_definition, Ngage.EventDefinitions
        field :contacted, :boolean, null: false, default: false
        field :dismissed, :boolean, null: false, default: false

        timestamps()
    end

    @required_fields ~w(customer_id event_definition_id)a
    @optional_fields ~w(contacted dismissed)a

    def changeset(event, params \\ %{}) do
        event
	|> cast(params, @optional_fields ++ @required_fields)
	|> validate_required(@required_fields)
	|> assoc_constraint(:customer)
	|> assoc_constraint(:event_definition)
    end
end
