defmodule PhoenixLogbaseApiWeb.ApiUserHelper do
  alias PhoenixLogbaseApi.Accounts.User

  def user_data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email
    }
  end
end
