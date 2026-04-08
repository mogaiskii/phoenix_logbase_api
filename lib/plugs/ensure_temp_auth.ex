defmodule PhoenixLogbaseApiWeb.EnsureTempAuth do
  use Guardian.Plug.Pipeline, otp_app: :phoenix_logbase_api,
                              module: PhoenixLogbaseApi.Guardian,
                              error_handler: PhoenixLogbaseApiWeb.AuthFallbackController

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "temp"}
  plug Guardian.Plug.EnsureAuthenticated
end
