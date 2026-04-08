defmodule PhoenixLogbaseApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string, redact: true
    field :totp_secret, :string, redact: true
    field :totp_enabled, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
    id: Ecto.UUID.t(),
    username: String.t(),
    email: String.t(),
    password_hash: String.t(),
    inserted_at: DateTime.t(),
    updated_at: DateTime.t(),
    totp_secret: String.t() | nil,
    totp_enabled: boolean()
  }

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password_hash, :totp_secret, :totp_enabled])
    |> validate_required([:username, :email, :password_hash])
  end
end
