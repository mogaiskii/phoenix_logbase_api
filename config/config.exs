# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :phoenix_logbase_api,
  ecto_repos: [PhoenixLogbaseApi.Repo],
  generators: [timestamp_type: :utc_datetime, api_prefix: "/api/v1", binary_id: true]

# Configure the endpoint
config :phoenix_logbase_api, PhoenixLogbaseApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: PhoenixLogbaseApiWeb.ErrorJSON],
    layout: false
  ]

config :phoenix_logbase_api, PhoenixLogbaseApi.Repo,
  migration_primary_key: [type: :uuid]

config :phoenix_logbase_api, PhoenixLogbaseApi.Guardian,
  issuer: "phoenix_logbase_api",
  secret_key: System.get_env("API_SECRET_KEY"),
  ttl: {1, :hour}

config :phoenix_logbase_api, PhoenixLogbaseApi.Accounts.Auth,
  issuer: "phoenix_logbase_api",
  refresh_token_expiry: {1, :day},
  temp_token_expiry: {5, :minutes}

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use Casex to encode JSON responses in camelCase
config :phoenix, :format_encoders, json: Casex.CamelCaseEncoder

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
