defmodule NgageWeb.CustomersController do
    use NgageWeb.Web, :controller

    import NgageWeb.Utils

    def list(conn, _params) do
        customers = Ngage.CustomerQueries.get_all()
        |> Enum.map(fn c -> sanitize(c) end)

        json conn, %{customers: customers}
    end
end