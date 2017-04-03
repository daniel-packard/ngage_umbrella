defmodule NgageWeb.EventDefinitionsController do
  use NgageWeb.Web, :controller

  def list(conn, _params) do
    eventDefinitions = Ngage.EventDefinitionQueries.get_all
    |> Enum.map (fn x -> sanitize(x) end)

    json conn, eventDefinitions
  end

  defp sanitize(map) do
    Map.drop(map, [:__meta__, :__struct__])
  end
end