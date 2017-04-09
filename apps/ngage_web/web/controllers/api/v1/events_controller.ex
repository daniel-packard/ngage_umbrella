defmodule NgageWeb.EventsController do
    use NgageWeb.Web, :controller

    import NgageWeb.Utils

    def list(conn, _params) do
        events = Ngage.EventQueries.get_all()
        |> Enum.map(fn e -> sanitize(e) end)

        render conn, "index.json", events: events
    end

    def create(conn, params) do
        new_event = params["event"]
        event_definition = Ngage.EventDefinitionQueries.get_by_id(new_event["event_definition_id"])
        event_definition_id = event_definition.id
        customer = get_or_create_customer_by_username(new_event["username"])
        customer_id = customer.id

        new_event = Ngage.EventQueries.create(Ngage.Events.changeset(%Ngage.Events{}, %{event_definition_id: event_definition_id, customer_id: customer_id}))

        result = sanitize(Ngage.EventQueries.get_by_id(new_event.id))
        json conn, %{event: result}
    end

    def update(conn, params) do
        event_id = params["id"]
        event = Ngage.EventQueries.get_by_id(event_id)

        updated_event = Ngage.EventQueries.update(Ngage.Events.changeset(event, params))

        json conn, updated_event
    end

    def get_or_create_customer_by_username(username) do
        customer = Ngage.CustomerQueries.get_by_username(username)

        result = case customer do
          :nil -> Ngage.CustomerQueries.create(Ngage.Customers.changeset(%Ngage.Customers{}, %{username: username}))
          _ -> customer
        end

        result
    end
end
