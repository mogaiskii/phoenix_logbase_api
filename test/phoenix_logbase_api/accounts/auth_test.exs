defmodule PhoenixLogbaseApiWeb.AuthTest do
  use PhoenixLogbaseApiWeb.ConnCase
  import PhoenixLogbaseApi.AccountsFixtures

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
  end
end
