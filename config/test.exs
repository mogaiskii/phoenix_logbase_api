import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :phoenix_logbase_api, PhoenixLogbaseApi.Repo,
  username: "postgres",
  password: "password",
  hostname: "localhost",
  database: "logbase_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_logbase_api, PhoenixLogbaseApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "QKEShADTcdLwLfoz9bc5HmAWYUnIxP8HLxosiVzgtoi2moxRF5OAEMHJXSHi1GbL",
  server: false

config :phoenix_logbase_api, PhoenixLogbaseApi.Guardian,
  issuer: "phoenix_logbase_api",
  secret_key: "luKO6tyHw3YNyOAcGzEPgvaErzNSdmyLdA6TVWkHRk-eP55zz7oKdiRJi8MNEDhO"

# In test we don't send emails
config :phoenix_logbase_api, PhoenixLogbaseApi.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
