defmodule InvoiceGenerator.Repo.Migrations.AddEmbeddedPicture do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :picture, :map
    end
  end
end
