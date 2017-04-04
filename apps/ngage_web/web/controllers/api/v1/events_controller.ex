defmodule NgageWeb.EventsController do
    use NgageWeb.Web, :controller

    import NgageWeb.Utils

    def list(conn, _params) do
        events = Ngage.EventQueries.get_all()
        |> Enum.map(fn e -> sanitize(e) end)

        json conn, %{events: events}
    end
end