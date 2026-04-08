defmodule PhoenixLogbaseApiWeb.AuthJSON do
  alias PhoenixLogbaseApiWeb.UserJSON

  import PhoenixLogbaseApiWeb.ApiResponseBuilder, only: [build_success: 2]

  def login(%{user: user, token: token, refresh_token: refresh_token, links: links}) do
    build_success(%{user: UserJSON.data(user), token: token, refresh_token: refresh_token}, links)
  end

  def refresh(%{token: token, links: links}) do
    build_success(%{token: token}, links)
  end

  def temp_login(%{token: token, links: links}) do
    build_success(%{temp_token: token}, links)
  end

end
