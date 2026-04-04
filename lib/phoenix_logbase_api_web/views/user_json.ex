defmodule PhoenixLogbaseApiWeb.UserJSON do
  alias PhoenixLogbaseApi.Accounts.User

  import PhoenixLogbaseApiWeb.ApiResponseBuilder, only: [build_success: 2]

  @doc """
  Renders a list of users.
  """
  def index(%{users: users, links: links}) do
    build_success(%{users: for(user <- users, do: data(user))}, links)
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user, links: links}) do
    build_success(%{user: data(user)}, links)
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email
    }
  end
end
