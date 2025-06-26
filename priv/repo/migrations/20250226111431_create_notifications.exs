defmodule InvoiceGenerator.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :product_updates, :boolean, default: false, null: false
      add :sign_in_notification, :boolean, default: false, null: false
      add :payment_reminders, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    # * user_id must be unique
    create unique_index(:notifications, [:user_id])
  end
end
