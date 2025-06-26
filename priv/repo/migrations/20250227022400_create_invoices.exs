defmodule InvoiceGenerator.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :from_address, :string
      add :from_city, :string
      add :from_post_code, :string
      add :from_country, :string
      add :to_client_name, :string
      add :to_client_email, :string
      add :to_address, :string
      add :to_city, :string
      add :to_post_code, :string
      add :to_country, :string
      add :invoice_date, :date
      add :invoice_due, :date
      add :project_description, :text
      add :invoice_state, :string
      add :items, :map

      timestamps(type: :utc_datetime)
    end
  end
end
