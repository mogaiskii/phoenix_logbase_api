defmodule PhoenixLogbaseApiWeb.AuthController do
  use PhoenixLogbaseApiWeb, :controller

  alias PhoenixLogbaseApi.Accounts.User
  alias PhoenixLogbaseApi.Accounts.Auth

  action_fallback PhoenixLogbaseApiWeb.FallbackController

  @login_schema %{
    "type" => "object",
    "properties" => %{
      "username" => %{"type" => "string"},
      "password" => %{"type" => "string"}
    },
    "required" => ["username", "password"]
  }
  @refresh_schema %{
    "type" => "object",
    "properties" => %{
      "refresh_token" => %{"type" => "string"}
    },
    "required" => ["refresh_token"]
  }
  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @login_schema, actions: [:login]
  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @refresh_schema, actions: [:refresh]

  def login(conn, %{"username" => username, "password" => password}) do
    with {:ok, %User{} = user} <- Auth.authenticate_user(username, password) do
      {token, refresh_token} = Auth.generate_token_pair(user)
      render(conn, :login, user: user, token: token, refresh_token: refresh_token, links: %{self: "/api/v1/auth/login"})
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, new_token} <- Auth.refresh_token(refresh_token) do
      render(conn, :refresh, token: new_token, links: %{self: "/api/v1/auth/refresh"})
    end
  end
end
