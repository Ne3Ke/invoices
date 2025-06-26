defmodule InvoiceGenerator.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  # * instead of up and down use change
  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      # * Use binary_id instead
      add :id, :binary_id, primary_key: true
      add :username, :string, null: false
      add :name, :string, null: false
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])

    create table(:users_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    create table(:profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # * defines a foreign key, you must explicitly set the type if using binary_ids
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :country, :string
      add :city, :string
      add :phone, :string
      add :postal_code, :string
      add :street, :string

      timestamps(type: :utc_datetime)
    end

    # * user_id must be unique
    create unique_index(:profiles, [:user_id])
  end
end
