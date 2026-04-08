defmodule PhoenixLogbaseApiWeb.NotFoundRouteTest do
  use PhoenixLogbaseApiWeb.ConnCase

  test "returns 404 for non-existent route", %{conn: conn} do
    conn = get(conn, "/api/v1/non_existent_route")
    assert hd(json_response(conn, 404)["errors"]) == %{"code" => 20001, "message" => "Resource not found"}
  end
end
