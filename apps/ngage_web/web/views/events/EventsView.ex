defmodule NgageWeb.EventsView do
  use NgageWeb.Web, :view

  def render("index.json", %{events: events}) do
    %{
      events: Enum.map(events, &event_json/1)
    }
  end

  def event_json(event) do
    %{
      id: event.id,
      customer: customer_json(event.customer),
      event_definition: event_definition_json(event.event_definition),
      contacted: event.contacted,
      dismissed: event.dismissed,
      inserted_at: event.inserted_at,
      updated_at: event.updated_at
    }
  end

  def customer_json(customer) do
    %{
      id: customer.id,
      username: customer.username
    }
  end

  def event_definition_json(event_definition) do
    %{
      id: event_definition.id,
      description: event_definition.description
    }
  end
end
