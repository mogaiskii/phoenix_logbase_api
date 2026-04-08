defmodule PhoenixLogbaseApiWeb.AuthTest do
  use PhoenixLogbaseApiWeb.ConnCase

  alias PhoenixLogbaseApi.Accounts
  alias PhoenixLogbaseApi.Accounts.User

  import PhoenixLogbaseApi.AccountsFixtures
  import PhoenixLogbaseApi.AccountsFixtures
  import PhoenixLogbaseApiWeb.PasswordHelper, only: [hash_password: 1]

  describe "authorize_and_get_user" do
    test "returns user when token is valid" do
      {token, user} = auth_fixture()
      assert {:ok, returned_user} = PhoenixLogbaseApi.Accounts.Auth.authorize_and_get_user(token)
      assert returned_user.id == user.id, "Returned user ID must match the authenticated user's ID"
      assert returned_user.email == user.email, "Returned user email must match the authenticated user's email"
      assert returned_user.username == user.username, "Returned username must match the authenticated user's username"
    end

    test "returns error when token is invalid" do
      assert {:error, _reason} = PhoenixLogbaseApi.Accounts.Auth.authorize_and_get_user("invalidtoken")
    end

    test "happy path works correctly" do
      user = user_fixture(password_hash: hash_password("validpassword"))
      {:ok, authenticated_user} = PhoenixLogbaseApi.Accounts.Auth.authenticate_user(user.username, "validpassword")
      assert authenticated_user.id == user.id, "Authenticated user ID must match the created user's ID"
      {token, refresh_token} = PhoenixLogbaseApi.Accounts.Auth.generate_token_pair(authenticated_user)
      assert {:ok, claims} = PhoenixLogbaseApi.Accounts.Auth.authorize_user(token)
      assert claims["sub"] == user.id, "Claims must contain the authenticated user's ID in the 'sub' field"
      assert claims["typ"] == "access", "Claims must indicate that this is an access token"
      assert {:ok, returned_user} = PhoenixLogbaseApi.Accounts.Auth.authorize_and_get_user(token)
      assert returned_user.id == user.id, "Returned user ID must match the authenticated user's ID"
      assert {:ok, new_token} = PhoenixLogbaseApi.Accounts.Auth.refresh_token(refresh_token), "Refreshing the token must succeed with a valid refresh token"
      assert new_token != token, "New token must be different from the old token"
      assert {:ok, new_claims} = PhoenixLogbaseApi.Accounts.Auth.authorize_user(new_token), "Authorizing with the new token must succeed"
      assert new_claims["sub"] == user.id, "New claims must contain the authenticated user's ID in the 'sub' field"
      assert new_claims["typ"] == "access", "New claims must indicate that this is an access token"
      assert {:ok, refreshed_user} = PhoenixLogbaseApi.Accounts.Auth.authorize_and_get_user(new_token), "Authorizing with the new token must succeed and return the user"
      assert refreshed_user.id == user.id, "Refreshed user ID must match the authenticated user's ID"
    end
  end

  describe "Auth/totp" do
    test "generate_totp_secret/0 generates a valid TOTP secret and URL" do
      assert {:ok, secret, url} = Accounts.Auth.generate_totp_secret()
      assert is_binary(secret) and byte_size(secret) > 0, "Secret must be a non-empty string"
      assert is_binary(url) and byte_size(url) > 0, "URL must be a non-empty string"
      assert String.starts_with?(url, "otpauth://totp/"), "URL must start with otpauth://totp/"
      assert String.contains?(url, secret), "URL must contain the generated secret"
    end

    test "verify_totp/2 correctly verifies valid and invalid TOTP codes" do
      secret = NimbleTOTP.secret()
      valid_code = NimbleTOTP.verification_code(secret)
      invalid_code = "000000" # Assuming this is not the valid code for the generated secret
      assert Accounts.Auth.verify_totp(%User{totp_secret: Base.encode32(secret)}, valid_code) == true, "Valid TOTP code must be verified successfully"
      assert Accounts.Auth.verify_totp(%User{totp_secret: Base.encode32(secret)}, invalid_code) == false, "Invalid TOTP code must not be verified"
    end
  end
end
