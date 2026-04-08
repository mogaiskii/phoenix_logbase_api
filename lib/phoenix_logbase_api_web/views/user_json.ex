defmodule PhoenixLogbaseApiWeb.UserJSON do
  import PhoenixLogbaseApiWeb.ApiResponseBuilder, only: [build_success: 2]
  import PhoenixLogbaseApiWeb.ApiUserHelper, only: [user_data: 1]

  @doc """
  Renders a list of users.
  """
  def index(%{users: users, links: links}) do
    build_success(%{users: for(user <- users, do: user_data(user))}, links)
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user, links: links}) do
    build_success(%{user: user_data(user)}, links)
  end
end
