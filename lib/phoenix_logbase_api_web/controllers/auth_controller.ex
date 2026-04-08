defmodule PhoenixLogbaseApiWeb.AuthController do
  use PhoenixLogbaseApiWeb, :controller

  plug PhoenixLogbaseApiWeb.EnsureTempAuth when action in [:login_code]

  action_fallback PhoenixLogbaseApiWeb.FallbackController

  alias PhoenixLogbaseApi.Accounts.User
  alias PhoenixLogbaseApi.Accounts.Auth

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
  @login_code_schema %{
    "type" => "object",
    "properties" => %{
      "code" => %{"type" => "string"}
    },
    "required" => ["code"]
  }
  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @login_schema, actions: [:login]
  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @refresh_schema, actions: [:refresh]
  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @login_code_schema, actions: [:login_code]

  def login(conn, %{"username" => username, "password" => password}) do
    with {:ok, %User{} = user} <- Auth.authenticate_user(username, password) do
      case user.totp_enabled do
        true -> send_temp_token(conn, user)
        false -> send_login_token(conn, user)
      end
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, new_token} <- Auth.refresh_token(refresh_token) do
      render(conn, :refresh, token: new_token, links: %{self: "/api/v1/auth/refresh"})
    end
  end

  def login_code(conn, %{"code" => code}) do
    with {:ok, %User{} = user} <- Auth.get_user_from_verified_token(conn) do
      case {user.totp_enabled, user.totp_secret} do
        {false, _}     -> {:error, :totp_not_enabled}  # todo: actionable error here with log
        {true, nil}    -> {:error, :unexpected_error}  # todo: actionable error here with log
        {true, _secret} -> case Auth.verify_totp(user, code) do
          true  -> send_login_token(conn, user, "/api/v1/auth/login/code")
          false -> {:error, :invalid_totp_code}
        end
      end
    end
  end

  defp send_temp_token(conn, user) do
    token = Auth.generate_temprorary_token(user)
    render(conn, :temp_login, token: token, links: %{self: "/api/v1/auth/login", next: "/api/v1/auth/login/code"})
  end

  defp send_login_token(conn, user, self_link \\ "/api/v1/auth/login") do
    {token, refresh_token} = Auth.generate_token_pair(user)
    render(conn, :login, user: user, token: token, refresh_token: refresh_token, links: %{self: self_link})
  end
end
