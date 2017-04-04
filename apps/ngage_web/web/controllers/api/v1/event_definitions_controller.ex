defmodule NgageWeb.EventDefinitionsController do
  use NgageWeb.Web, :controller

  import NgageWeb.Utils

  def list(conn, _params) do
    eventDefinitions = Ngage.EventDefinitionQueries.get_all()
      |> Enum.map(fn x -> sanitize(x) end)

    json conn, %{eventDefinitions: eventDefinitions}
  end

end