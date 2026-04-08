defmodule PhoenixLogbaseApiWeb.UserController do
  use PhoenixLogbaseApiWeb, :controller

  alias PhoenixLogbaseApi.Accounts
  alias PhoenixLogbaseApi.Accounts.User
  alias PhoenixLogbaseApi.Accounts.Auth

  action_fallback PhoenixLogbaseApiWeb.FallbackController

  @create_schema %{
    "type" => "object",
    "properties" => %{
      "username" => %{"type" => "string"},
      "email" => %{"type" => "string"},
      "password" => %{"type" => "string"}
    },
    "required" => ["username", "email", "password"]
  }

  @update_schema %{
    "type" => "object",
    "properties" => %{
      "username" => %{"type" => "string"},
      "email" => %{"type" => "string"},
      "password" => %{"type" => "string"}
    },
    "required" => ["username", "email"]
  }

  @totp_schema %{
    "type" => "object",
    "properties" => %{
      "code" => %{"type" => "string"}
    },
    "required" => ["code"]
  }

  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @create_schema, actions: [:create]
  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @update_schema, actions: [:update]
  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @totp_schema, actions: [:totp_confirm, :totp_remove]

  def index(conn, _params) do
    users = Accounts.list_users()
    index_with_links(conn, users)
  end

  def create(conn, %{"username" => username, "email" => email, "password" => password}) do
    with {:ok, %User{} = user} <- Accounts.create_user(%{username: username, email: email, password: password}) do
      conn
      |> put_status(:created)
      |> show_with_links(user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    show_with_links(conn, user)
  end

  def update(conn, %{"id" => id} = user_params) do
    user = Accounts.get_user!(id)
    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      show_with_links(conn, user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      show_with_links(conn, user)
    end
  end

  def totp_request(conn, _params) do
    with {:ok, %User{} = user} <- Auth.get_user_from_verified_token(conn) do
      case user.totp_enabled do
        true -> {:error, :totp_already_confirmed}

        false -> with {:ok, secret, url} <- Auth.generate_totp_secret() do
          with {:ok, %User{}} <- Accounts.update_user(user, %{totp_secret: secret}) do
            render(conn, :totp_request, url: url, links: %{self: ~p"/api/v1/users/totp"})
          end
        end
      end
    end
  end

  def totp_confirm(conn, %{"code" => code}) do
    with {:ok, %User{} = user} <- Auth.get_user_from_verified_token(conn) do
      case {user.totp_enabled, user.totp_secret} do
        {true, _} -> {:error, :totp_already_confirmed}
        {false, nil} -> {:error, :totp_not_requested}
        {false, _} -> confirm_totp(conn, user, code)
      end
    end
  end

  def totp_remove(conn, %{"code" => code}) do
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
        render(conn, :totp_confirm, message: "TOTP code is valid", links: %{self: ~p"/api/v1/users/totp/confirm"})
      end
    end
  end

  defp remove_totp(conn, user, code) do
    case Auth.verify_totp(user, code) do
      true -> with {:ok, %User{}} <- PhoenixLogbaseApi.Accounts.update_user(user, %{totp_enabled: false, totp_secret: nil}) do
        render(conn, :totp_remove, links: %{self: ~p"/api/v1/users/totp"})
      end
      false -> {:error, :invalid_totp_code}
    end
  end

  defp index_with_links(conn, users) do
    render(conn, :index, users: users, links: %{self: ~p"/api/v1/users"})
  end
  defp show_with_links(conn, %User{} = user) do
    render(conn, :show, user: user, links: user_links(user))
  end
  defp user_links(%User{id: id}), do: %{self: ~p"/api/v1/users/#{id}"}
end
