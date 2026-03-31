defmodule PhoenixLogbaseApiWeb.PingController do
  use PhoenixLogbaseApiWeb, :controller
  alias PhoenixLogbaseApiWeb.ApiResponseBuilder, as: ResponseBuilder

  def ping(conn, _params) do
    json(conn, ResponseBuilder.build_success(%{message: "pong"}, %{self: ""}))
  end
end
