defmodule Ngage.EventQueries do
    import Ecto.Query
    
    alias Ngage.{Repo, Events}

    def any do
        Repo.one(from e in Events, select: count(e.id)) != 0
    end

    def get_all do
        # Repo.all(from Events)
    end

    def get_by_id(id) do
        Repo.get(Events, id)
    end

    def create(event) do
        Repo.insert!(event)
    end

end