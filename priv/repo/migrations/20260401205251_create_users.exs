defmodule PhoenixLogbaseApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string, null: false, unique: true
      add :email, :string, null: false, unique: true
      add :password_hash, :text

      timestamps(type: :utc_datetime)
    end
    create index(:users, [:username])
  end
end
