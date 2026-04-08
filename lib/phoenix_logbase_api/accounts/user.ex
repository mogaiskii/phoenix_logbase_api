defmodule PhoenixLogbaseApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :username, :string
    field :email, :string, redact: true
    field :password_hash, :string

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
    id: Ecto.UUID.t(),
    username: String.t(),
    email: String.t(),
    password_hash: String.t(),
    inserted_at: DateTime.t(),
    updated_at: DateTime.t()
  }

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password_hash])
    |> validate_required([:username, :email, :password_hash])
  end
end
