defmodule PhoenixLogbaseApiWeb.Router do
  use PhoenixLogbaseApiWeb, :router
  use Plug.ErrorHandler

  @impl Plug.ErrorHandler
  def handle_errors(conn, _) do
    json(conn, PhoenixLogbaseApiWeb.ErrorJSON.render("500.json", %{self: conn.request_path || ""}))
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug PhoenixLogbaseApiWeb.EnsureSelf
  end

  scope "/api", PhoenixLogbaseApiWeb do
    pipe_through :api
    get "/ping", PingController, :ping
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:phoenix_logbase_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PhoenixLogbaseApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
