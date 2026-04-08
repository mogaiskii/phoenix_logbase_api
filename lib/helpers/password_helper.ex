defmodule PhoenixLogbaseApiWeb.PasswordHelper do

  @doc """
  Hashes a password using PBKDF2 and returns the updated attributes map with the password hash.
  """
  def hash_password(password) do
    Pbkdf2.hash_pwd_salt(password)
  end

  @doc """
  Verifies a user's password.
  """
  def verify_password(input_password, user_password_hash) do
    Pbkdf2.verify_pass(input_password, user_password_hash)
  end

  @doc """
  Performs a dry run of the password hashing function to mitigate timing attacks.
  """
  def dry_run_password() do
    Pbkdf2.no_user_verify()
  end
end
