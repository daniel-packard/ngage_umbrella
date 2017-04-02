defmodule Ngage.EventDefinitionQueries do
    import Ecto.Query

    alias Ngage.{Repo, EventDefinitions}

    def get_all do
        Repo.all(from EventDefinitions)
    end

    def get_by_id(id) do
        Repo.get(EventDefinitions, id)
    end
end