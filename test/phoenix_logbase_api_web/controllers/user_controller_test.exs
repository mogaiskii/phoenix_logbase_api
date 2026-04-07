defmodule PhoenixLogbaseApiWeb.UserControllerTest do
  use PhoenixLogbaseApiWeb.ConnCase

  import PhoenixLogbaseApi.AccountsFixtures
  alias PhoenixLogbaseApi.Accounts.User

  @create_attrs %{
    username: "some username",
    email: "some email",
    password: "some password_hash"
  }
  @update_attrs %{
    username: "some updated username",
    email: "some updated email",
    password: "some updated password_hash"
  }
  @missing_attrs %{}
  @invalid_attrs %{username: 123, email: 123, password: 123}
  @null_attrs %{username: nil, email: nil, password: nil}
  @half_correct_attrs %{username: "valid username", email: 123, password: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/users")
      assert json_response(conn, 200)["response"]["users"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["response"]["user"]

      conn = get(conn, ~p"/api/v1/users/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some email",
               "username" => "some username"
             } = json_response(conn, 200)["response"]["user"]
    end

    test "renders errors when data is missing", %{conn: conn} do
      url = ~p"/api/v1/users"
      conn = post(conn, url, @missing_attrs)
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" =>  ^url}} = json_response(conn, 400), "Status code must be 400, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 3, "There must be 3 validation errors for missing username, email, and password"
      assert Enum.sort(Enum.map(errors, & &1["path"])) == ["email", "password", "username"], "Validation errors must be for email, password, and username"
      assert Enum.all?(errors, fn er -> er["message"] == "Missing required field '#{er["path"]}'" end), "Validation error messages must indicate the missing field"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      url = ~p"/api/v1/users"
      conn = post(conn, url, @invalid_attrs)
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" =>  ^url}} = json_response(conn, 400), "Status code must be 400, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 3, "There must be 3 validation errors for invalid username, email, and password"
      assert Enum.sort(Enum.map(errors, & &1["path"])) == ["email", "password", "username"], "Validation errors must be for email, password, and username"
      assert Enum.all?(errors, fn er -> er["message"] == "Type mismatch. Expected String but got Integer." end), "Validation error messages must indicate the expected type"
    end

    test "renders errors when data is null", %{conn: conn} do
      url = ~p"/api/v1/users"
      conn = post(conn, url, @null_attrs)
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" =>  ^url}} = json_response(conn, 400), "Status code must be 400, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 3, "There must be 3 validation errors for null username, email, and password"
      assert Enum.sort(Enum.map(errors, & &1["path"])) == ["email", "password", "username"], "Validation errors must be for email, password, and username"
      assert Enum.all?(errors, fn er -> er["message"] == "Type mismatch. Expected String but got Null." end), "Validation error messages must indicate that null is not allowed for required string fields"
    end

    test "renders errors when data is half correct", %{conn: conn} do
      url = ~p"/api/v1/users"
      conn = post(conn, url, @half_correct_attrs)
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" =>  ^url}} = json_response(conn, 400), "Status code must be 400, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 2, "There must be 2 validation errors for invalid email and password"
      assert Enum.sort(Enum.map(errors, & &1["path"])) == ["email", "password"], "Validation errors must be for email and password"
      assert Enum.all?(errors, fn er ->
        case er["path"] do
          "email" -> er["message"] == "Type mismatch. Expected String but got Integer."
          "password" -> er["message"] == "Type mismatch. Expected String but got Null."
          _ -> false
        end
      end), "Validation error messages must indicate the expected type for each field"
    end
  end

  describe "get user" do
    setup [:create_user]
    test "renders user when id is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = get(conn, ~p"/api/v1/users/#{user}")
      assert %{
               "id" => ^id,
               "email" => "some email",
               "username" => "some username"
             } = json_response(conn, 200)["response"]["user"]
    end
    test "renders 404 when id is invalid", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/users/9445ca06-d638-4053-9f2f-34275da97374")
      end
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/v1/users/#{user}", @update_attrs)
      assert %{
               "id" => ^id,
               "email" => "some updated email",
               "username" => "some updated username"
             } = json_response(conn, 200)["response"]["user"]

      conn = get(conn, ~p"/api/v1/users/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some updated email",
               "username" => "some updated username"
             } = json_response(conn, 200)["response"]["user"]
    end

    test "renders errors when data is missing", %{conn: conn, user: user} do
      url = ~p"/api/v1/users/#{user}"
      conn = put(conn, url, @missing_attrs)
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" =>  ^url}} = json_response(conn, 400), "Status code must be 400, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 2, "There must be 2 validation errors for missing username and email"
      assert Enum.sort(Enum.map(errors, & &1["path"])) == ["email", "username"], "Validation errors must be for email and username"
      assert Enum.all?(errors, fn er -> er["message"] == "Missing required field '#{er["path"]}'" end), "Validation error messages must indicate the missing field"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/v1/users/#{user}")
      assert response(conn, 200)
      assert %{"id" => id, "email" => email, "username" => username} = json_response(conn, 200)["response"]["user"]
      assert %{
               "id" => ^id,
               "email" => ^email,
               "username" => ^username
             } = json_response(conn, 200)["response"]["user"]

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/users/#{user}")
      end
    end
  end

  defp create_user(_) do
    user = user_fixture()

    %{user: user}
  end
end
