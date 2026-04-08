defmodule PhoenixLogbaseApiWeb.TotpController do
  use PhoenixLogbaseApiWeb, :controller

  alias PhoenixLogbaseApi.Accounts
  alias PhoenixLogbaseApi.Accounts.Auth
  alias PhoenixLogbaseApi.Accounts.User

  action_fallback PhoenixLogbaseApiWeb.FallbackController

  @totp_schema %{
    "type" => "object",
    "properties" => %{
      "code" => %{"type" => "string"}
    },
    "required" => ["code"]
  }

  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @totp_schema, actions: [:confirm, :remove]

  def request(conn, _params) do
    with {:ok, %User{} = user} <- Auth.get_user_from_verified_token(conn) do
      case user.totp_enabled do
        true -> {:error, :totp_already_confirmed}

        false -> with {:ok, secret, url} <- Auth.generate_totp_secret() do
          with {:ok, %User{}} <- Accounts.update_user(user, %{totp_secret: secret}) do
            render(conn, :request, url: url, links: %{self: ~p"/api/v1/totp"})
          end
        end
      end
    end
  end

  def confirm(conn, %{"code" => code}) do
    with {:ok, %User{} = user} <- Auth.get_user_from_verified_token(conn) do
      case {user.totp_enabled, user.totp_secret} do
        {true, _} -> {:error, :totp_already_confirmed}
        {false, nil} -> {:error, :totp_not_requested}
        {false, _} -> confirm_totp(conn, user, code)
      end
    end
  end

  def remove(conn, %{"code" => code}) do
    with {:ok, %User{} = user} <- Auth.get_user_from_verified_token(conn) do
      case {user.totp_enabled, user.totp_secret} do
        {false, _} -> {:error, :totp_not_enabled}
        {true, nil} -> {:error, :invalid_totp_state}
        {true, _} -> remove_totp(conn, user, code)
      end
    end
  end

  defp confirm_totp(conn, user, code) do
    case Auth.verify_totp(user, code) do
      false -> {:error, :invalid_totp_code}
      true -> with {:ok, %User{}} <- Accounts.update_user(user, %{totp_enabled: true}) do
        render(conn, :confirm, message: "TOTP code is valid", links: %{self: ~p"/api/v1/totp/confirm"})
      end
    end
  end

  defp remove_totp(conn, user, code) do
    case Auth.verify_totp(user, code) do
      true -> with {:ok, %User{}} <- PhoenixLogbaseApi.Accounts.update_user(user, %{totp_enabled: false, totp_secret: nil}) do
        render(conn, :remove, links: %{self: ~p"/api/v1/totp"})
      end
      false -> {:error, :invalid_totp_code}
    end
  end

end
