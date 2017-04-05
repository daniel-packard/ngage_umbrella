defmodule Ngage.EventQueries do
    import Ecto.Query
    
    alias Ngage.{Repo, Events}

    def any do
        Repo.one(from e in Events, select: count(e.id)) != 0
    end

    def get_all do
        Repo.all(from Events) |> Repo.preload(:customer) |> Repo.preload(:event_definition)
    end

    def get_by_id(id) do
        Repo.get(Events, id) |> Repo.preload(:customer) |> Repo.preload(:event_definition)
    end

    def create(event) do
        Repo.insert!(event)
    end

end
