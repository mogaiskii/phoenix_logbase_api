defmodule PhoenixLogbaseApiWeb.UserController do
  use PhoenixLogbaseApiWeb, :controller

  alias PhoenixLogbaseApi.Accounts
  alias PhoenixLogbaseApi.Accounts.User

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

  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @create_schema, actions: [:create]
  plug PhoenixLogbaseApiWeb.ValidateRequest, schema: @update_schema, actions: [:update]

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

  defp index_with_links(conn, users) do
    render(conn, :index, users: users, links: %{self: ~p"/api/v1/users"})
  end
  defp show_with_links(conn, %User{} = user) do
    render(conn, :show, user: user, links: user_links(user))
  end
  defp user_links(%User{id: id}), do: %{self: ~p"/api/v1/users/#{id}"}
end
