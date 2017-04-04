defmodule Ngage.Customers do
    use Ecto.Schema

    import Ecto.Changeset

    @derive {Poison.Encoder, except: [:__meta__]}
    schema "customers" do
        field :username, :string
    end

    @required_fields ~w(username)a

    def changeset(customer, params \\ %{}) do
        customer 
        |> cast(params, @required_fields)
        |> validate_required(@required_fields)
    end

end
