defmodule Ngage.CustomerQueries do
    import Ecto.Query
    
    alias Ngage.{Repo, Customers}

    def any do
        Repo.one(from c in Customers, select: count(c.id)) != 0
    end

    def get_all do
        Repo.all(from Customers)
    end

    def get_by_id(id) do
        Repo.get(Customers, id)
    end

    def create(customer) do
        Repo.insert!(customer)
    end

end