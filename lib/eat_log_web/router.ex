defmodule EatLogWeb.Router do
  use EatLogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", EatLogWeb do
    pipe_through :api

    post "/sessions", SessionsController, :create
  end

  scope "/", EatLogWeb do
    pipe_through :browser
    get "/*path", FallbackController, :index
  end

  if Application.compile_env(:eat_log, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
