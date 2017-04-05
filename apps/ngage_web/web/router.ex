defmodule NgageWeb.Router do
  use NgageWeb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NgageWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", NgageWeb do 
    pipe_through :api

    get "/event_definitions", EventDefinitionsController, :list
    get "/customers", CustomersController, :list
    get "/events", EventsController, :list
    post "/events", EventsController, :create
  end
end
