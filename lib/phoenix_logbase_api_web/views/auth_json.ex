defmodule PhoenixLogbaseApiWeb.AuthJSON do
  import PhoenixLogbaseApiWeb.ApiResponseBuilder, only: [build_success: 2]
  import PhoenixLogbaseApiWeb.ApiUserHelper, only: [user_data: 1]

  def login(%{user: user, token: token, refresh_token: refresh_token, links: links}) do
    build_success(%{user: user_data(user), token: token, refresh_token: refresh_token}, links)
  end

  def refresh(%{token: token, links: links}) do
    build_success(%{token: token}, links)
  end

  def temp_login(%{token: token, links: links}) do
    build_success(%{temp_token: token}, links)
  end

end
