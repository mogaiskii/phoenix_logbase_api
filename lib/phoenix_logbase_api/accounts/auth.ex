defmodule PhoenixLogbaseApi.Accounts.Auth do
  import PhoenixLogbaseApiWeb.PasswordHelper, only: [verify_password: 2, dry_run_password: 0]
  import PhoenixLogbaseApi.Accounts, only: [get_user_by_username: 1]
  import PhoenixLogbaseApi.Guardian, only: [encode_and_sign: 1, encode_and_sign: 3, decode_and_verify: 1, exchange: 3]

  @doc """
  Authenticates a user by username and password.
  """
  @spec authenticate_user(binary(), binary()) :: {:error, :invalid_password} | {:ok, PhoenixLogbaseApi.Accounts.User.t()}
  def authenticate_user(username, password) do
    user = get_user_by_username(username)

    cond do
      user && verify_password(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :invalid_password}

      true ->
        # Perform a dummy password check to mitigate timing attacks
        dry_run_password()
        {:error, :invalid_password}
    end
  end

  def authorize_user(token) do
    case decode_and_verify(token) do
      {:ok, claims} -> {:ok, claims}
      {:error, reason} -> {:error, reason}
    end
  end

  def authorize_and_get_user(token) do
    case decode_and_verify(token) do
      {:ok, claims} -> PhoenixLogbaseApi.Guardian.resource_from_claims(claims)
      {:error, reason} -> {:error, reason}
    end
  end

  def get_user_from_verified_token(conn) do
    PhoenixLogbaseApi.Guardian.Plug.current_claims(conn)
    |> PhoenixLogbaseApi.Guardian.resource_from_claims()
  end

  def generate_token(user) do
    {:ok, token, _claims} = encode_and_sign(user)
    token
  end

  def generate_refresh_token(user) do
    {:ok, token, _claims} = encode_and_sign(user, %{}, token_type: "refresh", ttl: Application.get_env(:phoenix_logbase_api, __MODULE__)[:refresh_token_expiry])
    token
  end

  def generate_token_pair(user) do
    {generate_token(user), generate_refresh_token(user)}
  end

  def refresh_token(refresh_token) do
    case exchange(refresh_token, "refresh", "access") do
      {:ok, {_old_token, _old_claims}, {new_token, _new_claims}} -> {:ok, new_token}
      {:error, reason} -> {:error, reason}
    end
  end

  def generate_totp_secret() do
    secret = NimbleTOTP.secret()
    issuer = Application.get_env(:phoenix_logbase_api, __MODULE__)[:issuer]
    url = NimbleTOTP.otpauth_uri(issuer, secret, issuer: issuer)
    {:ok, Base.encode32(secret), url}
  end

  @spec verify_totp(PhoenixLogbaseApi.Accounts.User.t(), binary()) :: boolean()
  def verify_totp(%{totp_secret: secret}, token) do
    NimbleTOTP.valid?(Base.decode32!(secret), token)
  end
end
