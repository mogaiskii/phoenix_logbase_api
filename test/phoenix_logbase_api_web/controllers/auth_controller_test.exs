defmodule PhoenixLogbaseApiWeb.AuthControllerTest do
  use PhoenixLogbaseApiWeb.ConnCase

  import PhoenixLogbaseApi.AccountsFixtures

  import PhoenixLogbaseApiWeb.PasswordHelper, only: [hash_password: 1]

  alias PhoenixLogbaseApi.Accounts.Auth

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "user_authorization" do
    test "authenticates user and returns token when credentials are valid", %{conn: conn} do
      user = user_fixture(password_hash: hash_password("validpassword"))
      conn = post(conn, ~p"/api/v1/auth/login", %{username: user.username, password: "validpassword"})
      assert %{"code" => 0, "links" => %{"self" => "/api/v1/auth/login"}, "response" => %{"refreshToken" => refresh_token, "token" => token, "user" => user_data}} = json_response(conn, 200), "Status code must be 200, response must contain a token, refresh token and self link to the endpoint"
      assert is_binary(token) and byte_size(token) > 0, "Token must be a non-empty string"
      assert is_binary(refresh_token) and byte_size(refresh_token) > 0, "Refresh token must be a non-empty string"
      assert user_data == %{"id" => user.id, "email" => user.email, "username" => user.username}, "Response must contain the authenticated user's data"
    end

    test "returns error when credentials are invalid", %{conn: conn} do
      user = user_fixture(password_hash: hash_password("validpassword"))
      url = ~p"/api/v1/auth/login"
      conn = post(conn, url, %{username: user.username, password: "invalidpassword"})
      assert %{"code" => 30003, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 401), "Status code must be 401 for unauthorized access, error code must be 30003 for invalid password errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one error message for invalid credentials"
      assert Enum.at(errors, 0)["message"] == "Invalid password", "Error message must indicate that the username or password is invalid"
    end

    test "returns error when required fields are missing", %{conn: conn} do
      url = ~p"/api/v1/auth/login"
      conn = post(conn, url, %{})
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 400), "Status code must be 400 for bad request, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 2, "There must be exactly two validation errors for missing username and password"
      assert Enum.sort(Enum.map(errors, & &1["path"])) == ["password", "username"], "Validation errors must be for username and password"
      assert Enum.all?(errors, fn er ->
        case er["path"] do
          "username" -> er["message"] == "Missing required field 'username'"
          "password" -> er["message"] == "Missing required field 'password'"
          _ -> false
        end
      end), "Validation error messages must indicate that the field can't be blank for each missing field"
    end

    test "returns error when fields are of invalid type", %{conn: conn} do
      url = ~p"/api/v1/auth/login"
      conn = post(conn, url, %{username: 123, password: nil})
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 400), "Status code must be 400 for bad request, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 2, "There must be exactly two validation errors for invalid username and password types"
      assert Enum.sort(Enum.map(errors, & &1["path"])) == ["password", "username"], "Validation errors must be for username and password"
      assert Enum.all?(errors, fn er ->
        case er["path"] do
          "username" -> er["message"] == "Type mismatch. Expected String but got Integer."
          "password" -> er["message"] == "Type mismatch. Expected String but got Null."
          _ -> false
        end
      end), "Validation error messages must indicate that the field is invalid for each field with invalid type"
    end

    test "returns error when user does not exist", %{conn: conn} do
      url = ~p"/api/v1/auth/login"
      conn = post(conn, url, %{username: "nonexistentuser", password: "somepassword"})
      assert %{"code" => 30003, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 401), "Status code must be 401 for unauthorized access, error code must be 30003 for invalid password errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one error message for non-existent user"
      assert Enum.at(errors, 0)["message"] == "Invalid password", "Error message must indicate that the username or password is invalid for non-existent user"
    end
  end

  describe "refresh_token" do
    test "refreshes token when refresh token is valid", %{conn: conn} do
      {_, user} = auth_fixture()
      token = Auth.generate_refresh_token(user)
      url = ~p"/api/v1/auth/refresh"
      conn = post(conn, url, %{refreshToken: token})
      assert %{"code" => 0, "links" => %{"self" => "/api/v1/auth/refresh"}, "response" => %{"token" => new_token}} = json_response(conn, 200), "Status code must be 200 for successful token refresh, response must contain new token and self link to the endpoint"
      assert is_binary(new_token) and byte_size(new_token) > 0, "New token must be a non-empty string"
      assert new_token != token, "New token must be different from the old token"
    end

    test "returns error when refresh token is of invalid type", %{conn: conn} do
      url = ~p"/api/v1/auth/refresh"
      {token, _} = auth_fixture()
      conn = post(conn, url, %{refreshToken: token})
      assert %{"code" => 30000, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 401), "Status code must be 401 for unauthorized access, error code must be 30000 for authentication errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one error message for invalid refresh token"
      assert Enum.at(errors, 0)["message"] == "Invalid token", "Error message must indicate that the refresh token is invalid"
    end

    test "returns error when refresh token is invalid", %{conn: conn} do
      url = ~p"/api/v1/auth/refresh"
      conn = post(conn, url, %{refreshToken: "invalidtoken"})
      assert %{"code" => 30000, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 401), "Status code must be 401 for unauthorized access, error code must be 30000 for authentication errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one error message for invalid refresh token"
      assert Enum.at(errors, 0)["message"] == "Invalid token", "Error message must indicate that the refresh token is invalid"
    end

    test "returns error when refresh token is missing", %{conn: conn} do
      url = ~p"/api/v1/auth/refresh"
      conn = post(conn, url, %{})
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 400), "Status code must be 400 for bad request, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one validation error for missing refresh token"
      assert Enum.at(errors, 0)["message"] == "Missing required field 'refresh_token'", "Error message must indicate that the refreshToken field is required"
    end
  end

end
