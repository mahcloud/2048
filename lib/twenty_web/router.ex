defmodule TwentyWeb.Router do
  use TwentyWeb, :router

  pipeline :dashboard do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :liveview do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TwentyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TwentyWeb do
    pipe_through :liveview

    live "/", PageLive, :index
  end

  scope "/", TwentyWeb do
    pipe_through :browser

    get "/games/", GamesController, :index
    get "/games/new", GamesController, :new
    post "/games/new", GamesController, :create
    get "/games/:name", GamesController, :view
    post "/games/:name", GamesController, :combine
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwentyWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :dashboard
      live_dashboard "/dashboard", metrics: TwentyWeb.Telemetry
    end
  end
end
