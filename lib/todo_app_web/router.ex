defmodule TodoAppWeb.Router do
  use TodoAppWeb, :router

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

  scope "/", TodoAppWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/toggle/:id", PageController, :toggle
    get "/delete/:id", PageController, :delete

    post "/create", PageController, :create
  end

  # Other scopes may use custom stacks.
  scope "/api", TodoAppWeb do
    pipe_through :api

    get "/todos", TodoController, :get_users
    get "/todos/toggle/:id", TodoController, :togglestatus
    get "/todos/delete/:id", TodoController, :delete
    post "/todos/create", TodoController, :create_task
  end

  scope "/elm", TodoAppWeb do
    pipe_through :browser

    get "/", ElmController, :index
  end
end
