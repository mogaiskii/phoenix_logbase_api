defmodule PhoenixLogbaseApi.Repo.Migrations.UsersAddTotpSecretColumn do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :totp_secret, :string, null: true
      add :totp_enabled, :boolean, default: false, null: false
    end
  end
end
