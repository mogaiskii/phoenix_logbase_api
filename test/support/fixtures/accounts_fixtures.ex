defmodule PhoenixLogbaseApi.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhoenixLogbaseApi.Accounts` context.
  """
  alias PhoenixLogbaseApi.Accounts.Auth

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        password_hash: "some password_hash",
        username: "some username"
      })
      |> PhoenixLogbaseApi.Accounts.create_user()

    user
  end

  def auth_fixture(attrs \\ %{}) do
    with user <- user_fixture(attrs) do
      {Auth.generate_token(user), user}
    end
  end
end
