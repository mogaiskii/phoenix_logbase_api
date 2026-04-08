defmodule PhoenixLogbaseApi.Guardian do
  use Guardian, otp_app: :phoenix_logbase_api

  alias PhoenixLogbaseApi.Accounts

  def subject_for_token(user, _claims) do
    # You can use the user's ID as the subject of the token
    sub = to_string(user.id)
    {:ok, sub}
  end

  @spec resource_from_claims(nil | maybe_improper_list() | map()) :: {:ok, PhoenixLogbaseApi.Accounts.User.t()} | {:error, atom()}
  def resource_from_claims(claims) do
    # You can retrieve the user from the claims and return it
    id = claims["sub"]
    case Accounts.get_user(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
