defmodule InvoiceGenerator.RecordsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceGenerator.Records` context.
  """

  @doc """
  Generate a invoice.
  """
  def invoice_fixture(attrs \\ %{}) do
    {:ok, invoice} =
      attrs
      |> Enum.into(%{
        from_address: "some from_address",
        from_city: "some from_city",
        from_country: "some from_country",
        from_post_code: "some from_post_code",
        invoice_date: ~D[2025-02-26],
        invoice_due: ~D[2025-02-26],
        invoice_state: "some invoice_state",
        project_description: "some project_description",
        to_address: "some to_address",
        to_city: "some to_city",
        to_client_email: "some to_client_email",
        to_client_name: "some to_client_name",
        to_country: "some to_country",
        to_post_code: "some to_post_code"
      })
      |> InvoiceGenerator.Records.create_invoice()

    invoice
  end
end
