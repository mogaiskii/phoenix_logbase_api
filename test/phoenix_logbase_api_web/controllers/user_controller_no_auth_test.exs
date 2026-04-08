defmodule PhoenixLogbaseApiWeb.UserControllerNoAuthTest do
  use PhoenixLogbaseApiWeb.ConnCase

  import PhoenixLogbaseApi.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "user_controller_auth" do
    test "requires authentication for index", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/users")
      assert json_response(conn, 401)["errors"] == [%{"message" => "Unauthorized", "code" => 30002}], "Unauthenticated requests to the index endpoint should return a 401 status with an appropriate error message"
    end

    test "requires authentication for create", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", %{
        username: "testuser",
        email: "testuser@example.com",
        password: "password"
      })
      assert json_response(conn, 401)["errors"] == [%{"message" => "Unauthorized", "code" => 30002}], "Unauthenticated requests to the create endpoint should return a 401 status with an appropriate error message"
    end

    test "requires authentication for show", %{conn: conn} do
      user = user_fixture()
      conn = get(conn, ~p"/api/v1/users/#{user.id}")
      assert json_response(conn, 401)["errors"] == [%{"message" => "Unauthorized", "code" => 30002}], "Unauthenticated requests to the show endpoint should return a 401 status with an appropriate error message"
    end

    test "requires authentication for update", %{conn: conn} do
      user = user_fixture()
      conn = put(conn, ~p"/api/v1/users/#{user.id}", %{
        username: "updateduser",
        email: "updateduser@example.com",
        password: "newpassword"
      })
      assert json_response(conn, 401)["errors"] == [%{"message" => "Unauthorized", "code" => 30002}], "Unauthenticated requests to the update endpoint should return a 401 status with an appropriate error message"
    end

    test "requires authentication for delete", %{conn: conn} do
      user = user_fixture()
      conn = delete(conn, ~p"/api/v1/users/#{user.id}")
      assert json_response(conn, 401)["errors"] == [%{"message" => "Unauthorized", "code" => 30002}], "Unauthenticated requests to the delete endpoint should return a 401 status with an appropriate error message"
    end

  end


end
