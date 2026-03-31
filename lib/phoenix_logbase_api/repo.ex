defmodule PhoenixLogbaseApi.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_logbase_api,
    adapter: Ecto.Adapters.Postgres
end
