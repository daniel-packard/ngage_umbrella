defmodule NgageWeb.PageController do
  use NgageWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
