defmodule PhoenixLogbaseApiWeb.TotpControllerTest do
  use PhoenixLogbaseApiWeb.ConnCase

  import PhoenixLogbaseApi.AccountsFixtures
  alias PhoenixLogbaseApi.Accounts
  alias PhoenixLogbaseApi.Accounts.User

  setup %{conn: conn} do
    {token, default_user} = auth_fixture()
    authorized_conn = conn |> put_req_header("accept", "application/json") |> put_req_header("authorization", "Bearer #{token}")
    {:ok, conn: authorized_conn, default_user: default_user}
  end

  describe "TOTP management" do
    test "requests TOTP secret for authenticated user", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/totp")
      assert %{"code" => 0, "links" => %{"self" => "/api/v1/totp"}, "response" => %{"totpLink" => totp_link}} = json_response(conn, 200), "Status code must be 200, response must contain totp_link and self link to the endpoint"
      assert is_binary(totp_link) and byte_size(totp_link) > 0, "TOTP link must be a non-empty string"
    end

    test "returns error when requesting TOTP secret without authentication", _opts do
      unauthenticated_conn = build_conn() |> put_req_header("accept", "application/json")
      url = ~p"/api/v1/totp"
      conn = post(unauthenticated_conn, url)
      assert %{"code" => 30002, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 401), "Status code must be 401 for unauthorized access, error code must be 30002 for authentication errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one error message for unauthenticated access"
      assert Enum.at(errors, 0)["message"] == "Unauthorized", "Error message must indicate that authentication is required"
    end

    test "returns error when requesting TOTP when TOTP is already enabled", %{conn: conn} do
      {token, user} = auth_fixture()
      conn = conn |> put_req_header("accept", "application/json") |> put_req_header("authorization", "Bearer #{token}")
      {:ok, %User{}} = PhoenixLogbaseApi.Accounts.update_user(user, %{totp_enabled: true, totp_secret: "somesecret"})

      # Attempt to request a TOTP secret again when TOTP is already enabled
      conn = post(conn, ~p"/api/v1/totp")
      assert %{"code" => 30004, "errors" => errors, "links" => %{"self" => "/api/v1/totp"}} = json_response(conn, 400), "Status code must be 400 for bad request, error code must be 30005 for TOTP already enabled error, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one error message for requesting TOTP when it's already enabled"
      assert Enum.at(errors, 0)["message"] == "TOTP already confirmed", "Error message must indicate that TOTP is already enabled"
    end

    test "confirms TOTP code for authenticated user", %{conn: conn, default_user: user} do
      secret = NimbleTOTP.secret()
      {:ok, _user} = Accounts.update_user(user, %{totp_enabled: false, totp_secret: Base.encode32(secret)})

      totp_code = NimbleTOTP.verification_code(secret)

      # Now confirm the TOTP code
      conn = post(conn, ~p"/api/v1/totp/confirm", %{"code" => totp_code})
      assert %{"code" => 0, "links" => %{"self" => "/api/v1/totp/confirm"}, "response" => %{}} = json_response(conn, 200), "Status code must be 200, response must contain self link to the endpoint"
    end

    test "returns error when confirming TOTP code with invalid code", %{conn: conn, default_user: user} do
      {:ok, _user} = Accounts.update_user(user, %{totp_enabled: false, totp_secret: Base.encode32(NimbleTOTP.secret())})
      conn = post(conn, ~p"/api/v1/totp/confirm", %{"code" => "invalidcode"})
      assert %{"code" => 30006, "errors" => errors, "links" => %{"self" => "/api/v1/totp/confirm"}} = json_response(conn, 400), "Status code must be 401 for unauthorized access, error code must be 30004 for invalid TOTP code, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one error message for invalid TOTP code"
      assert Enum.at(errors, 0)["message"] == "Invalid TOTP code", "Error message must indicate that the TOTP code is invalid"
    end

    test "returns error when confirming TOTP code without requesting it first", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/totp/confirm", %{"code" => "somecode"})
      assert %{"code" => 30005, "errors" => errors, "links" => %{"self" => "/api/v1/totp/confirm"}} = json_response(conn, 400), "Status code must be 401 for unauthorized access, error code must be 30004 for invalid TOTP code, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one error message for confirming TOTP code without requesting it first"
      assert Enum.at(errors, 0)["message"] == "TOTP not requested", "Error message must indicate that TOTP was not requested"
    end

    test "returns error when confirming TOTP code that is already confirmed", %{conn: conn, default_user: user} do
      {:ok, secret, _url} = PhoenixLogbaseApi.Accounts.Auth.generate_totp_secret()
      {:ok, %User{}} = PhoenixLogbaseApi.Accounts.update_user(user, %{totp_enabled: true, totp_secret: secret})

      # Generate a valid TOTP code using the extracted secret
      totp_code = NimbleTOTP.verification_code(Base.encode32(secret))

      # Attempt to confirm the same TOTP code again
      conn = post(conn, ~p"/api/v1/totp/confirm", %{"code" => totp_code})
      assert %{"code" => 30004, "errors" => errors, "links" => %{"self" => "/api/v1/totp/confirm"}} = json_response(conn, 400), "Status code must be 401 for unauthorized access, error code must be 30004 for invalid TOTP code, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one error message for confirming an already confirmed TOTP code"
      assert Enum.at(errors, 0)["message"] == "TOTP already confirmed", "Error message must indicate that the TOTP code has already been confirmed"
    end

    test "removes TOTP for authenticated user", %{conn: conn, default_user: user} do
      {:ok, secret, _url} = PhoenixLogbaseApi.Accounts.Auth.generate_totp_secret()
      {:ok, %User{}} = PhoenixLogbaseApi.Accounts.update_user(user, %{totp_enabled: true, totp_secret: secret})

      code = NimbleTOTP.verification_code(Base.decode32!(secret))
      conn = delete(conn, ~p"/api/v1/totp", %{"code" => code})
      assert %{"code" => 0, "links" => %{"self" => "/api/v1/totp"}} = json_response(conn, 200), "Status code must be 200 for successful TOTP removal, code must be 0, and response must contain self link to the endpoint"
    end

    test "returns error when removing TOTP for user without TOTP enabled", %{conn: conn} do
      conn = delete(conn, ~p"/api/v1/totp", %{"code" => "012345"})
      assert %{"code" => 30007, "errors" => errors, "links" => %{"self" => "/api/v1/totp"}} = json_response(conn, 400), "Status code must be 400 for bad request, error code must be 30006 for TOTP not enabled error, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one error message for removing TOTP when it's not enabled"
      assert Enum.at(errors, 0)["message"] == "TOTP not enabled", "Error message must indicate that TOTP is not enabled for the user"
    end

    test "returns error when confirming TOTP code with invalid type", %{conn: conn} do
      url = ~p"/api/v1/totp/confirm"
      conn = post(conn, url, %{"code" => 12345})
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 400), "Status code must be 400 for bad request, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one validation error for invalid code type"
      assert Enum.at(errors, 0)["message"] == "Type mismatch. Expected String but got Integer.", "Error message must indicate that the code field has an invalid type"
    end

    test "returns error when confirming TOTP code with null value", %{conn: conn} do
      url = ~p"/api/v1/totp/confirm"
      conn = post(conn, url, %{"code" => nil})
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 400), "Status code must be 400 for bad request, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one validation error for null code value"
      assert Enum.at(errors, 0)["message"] == "Type mismatch. Expected String but got Null.", "Error message must indicate that the code field cannot be null and has an invalid type"
    end

    test "returns error when confirming TOTP code with missing code field", %{conn: conn} do
      url = ~p"/api/v1/totp/confirm"
      conn = post(conn, url, %{})
      assert %{"code" => 20000, "errors" => errors, "links" => %{"self" => ^url}} = json_response(conn, 400), "Status code must be 400 for bad request, error code must be 20000 for validation errors, and response must contain self link to the endpoint"
      assert Enum.count(errors) == 1, "There must be exactly one validation error for missing code field"
      assert Enum.at(errors, 0)["message"] == "Missing required field 'code'", "Error message must indicate that the code field is required and missing"
    end

    test "happy path for TOTP setup, confirmation, and removal", %{conn: conn, default_user: user} do
      # sanity check
      assert (not user.totp_enabled) and is_nil(user.totp_secret), "sanity check"

      # Request TOTP secret
      conn = post(conn, ~p"/api/v1/totp")
      assert %{"code" => 0, "links" => %{"self" => "/api/v1/totp"}, "response" => %{"totpLink" => totp_link}} = json_response(conn, 200), "Status code must be 200 and response must contain totp_link"
      assert is_binary(totp_link) and byte_size(totp_link) > 0, "TOTP link must be a non-empty string"

      %URI{query: query} = URI.parse(totp_link)
      %{"secret" => secret} = URI.decode_query(query)
      user = Accounts.get_user!(user.id)
      assert (not user.totp_enabled) and (not is_nil(user.totp_secret)), "TOTP must not be enabled, TOTP secret must be set after TOTP request call"
      assert user.totp_secret == secret, "TOTP request call must return the same secret that is put into db"

      # Generate a valid TOTP code using the extracted secret
      totp_code = NimbleTOTP.verification_code(Base.decode32!(secret))

      # Confirm the TOTP code
      conn = post(conn, ~p"/api/v1/totp/confirm", %{"code" => totp_code})
      assert %{"code" => 0} = json_response(conn, 200), "Confirmation of TOTP code must succeed with status code 200 and code 0 in response"

      user = Accounts.get_user!(user.id)
      assert user.totp_enabled and (not is_nil(user.totp_secret)), "TOTP must be enabled after confirmation call"

      # Remove TOTP
      conn = delete(conn, ~p"/api/v1/totp", %{"code" => totp_code})
      assert %{"code" => 0} = json_response(conn, 200), "TOTP removal must succeed with status code 200 and code 0 in response"
    end
  end
end
