defmodule PhoenixLogbaseApiWeb.PingControllerTest do
  use PhoenixLogbaseApiWeb.ConnCase

  test "ping returns pong", %{conn: conn} do
    conn = get(conn, ~p"/api/ping")
    assert json_response(conn, 200) == %{"response" => %{"message" => "pong"}, "code" => 0, "links" => %{"self" => "/api/ping"}}, "The ping endpoint should return a 200 status with a message of 'pong'"
  end
end
