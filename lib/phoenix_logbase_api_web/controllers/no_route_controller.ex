defmodule PhoenixLogbaseApiWeb.NoRouteController do
  @moduledoc """
  A module to handle no route found.
  """

  use PhoenixLogbaseApiWeb, :controller

  def not_found(conn, _) do
    conn
    |> put_status(404)
    |> put_resp_content_type("application/json")
    |> json(PhoenixLogbaseApiWeb.ErrorJSON.render("404.json", %{self: conn.request_path || "", code: 404}))
  end
end
