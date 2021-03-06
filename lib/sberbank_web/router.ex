defmodule SberbankWeb.Router do
  use SberbankWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {SberbankWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SberbankWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/employers", EmployerController do
      live "/tickets", OperatorTicketsLive
    end

    resources "/competencies", CompetenceController

    resources "/customers", CustomerController do
      resources "/tickets", CustomerTicketsController, only: [:index, :create, :update, :delete]
    end

    resources "/tickets", TicketController
  end

  # Other scopes may use custom stacks.
  # scope "/api", SberbankWeb do
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
      pipe_through :browser
      live_dashboard "/dashboard", metrics: SberbankWeb.Telemetry
    end
  end
end
