defmodule NgageWeb.Utils do
  def sanitize(map) do
    Map.drop(map, [:__meta__, :__struct__])
  end 
end