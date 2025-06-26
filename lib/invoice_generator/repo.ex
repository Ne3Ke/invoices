defmodule InvoiceGenerator.Repo do
  use Ecto.Repo,
    otp_app: :invoice_generator,
    adapter: Ecto.Adapters.Postgres

  # def installed_extensions do
  #   ["uuid-ossp", "citext"]
  # end
end
