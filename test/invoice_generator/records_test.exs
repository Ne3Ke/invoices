defmodule InvoiceGenerator.RecordsTest do
  use InvoiceGenerator.DataCase

  alias InvoiceGenerator.Records

  describe "invoices" do
    alias InvoiceGenerator.Records.Invoice

    import InvoiceGenerator.RecordsFixtures

    @invalid_attrs %{
      to_address: nil,
      from_address: nil,
      from_city: nil,
      from_post_code: nil,
      from_country: nil,
      to_client_name: nil,
      to_client_email: nil,
      to_city: nil,
      to_post_code: nil,
      to_country: nil,
      invoice_date: nil,
      invoice_due: nil,
      project_description: nil,
      invoice_state: nil
    }

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Records.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Records.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      valid_attrs = %{
        to_address: "some to_address",
        from_address: "some from_address",
        from_city: "some from_city",
        from_post_code: "some from_post_code",
        from_country: "some from_country",
        to_client_name: "some to_client_name",
        to_client_email: "some to_client_email",
        to_city: "some to_city",
        to_post_code: "some to_post_code",
        to_country: "some to_country",
        invoice_date: ~D[2025-02-26],
        invoice_due: ~D[2025-02-26],
        project_description: "some project_description",
        invoice_state: "some invoice_state"
      }

      assert {:ok, %Invoice{} = invoice} = Records.create_invoice(valid_attrs)
      assert invoice.to_address == "some to_address"
      assert invoice.from_address == "some from_address"
      assert invoice.from_city == "some from_city"
      assert invoice.from_post_code == "some from_post_code"
      assert invoice.from_country == "some from_country"
      assert invoice.to_client_name == "some to_client_name"
      assert invoice.to_client_email == "some to_client_email"
      assert invoice.to_city == "some to_city"
      assert invoice.to_post_code == "some to_post_code"
      assert invoice.to_country == "some to_country"
      assert invoice.invoice_date == ~D[2025-02-26]
      assert invoice.invoice_due == ~D[2025-02-26]
      assert invoice.project_description == "some project_description"
      assert invoice.invoice_state == "some invoice_state"
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Records.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()

      update_attrs = %{
        to_address: "some updated to_address",
        from_address: "some updated from_address",
        from_city: "some updated from_city",
        from_post_code: "some updated from_post_code",
        from_country: "some updated from_country",
        to_client_name: "some updated to_client_name",
        to_client_email: "some updated to_client_email",
        to_city: "some updated to_city",
        to_post_code: "some updated to_post_code",
        to_country: "some updated to_country",
        invoice_date: ~D[2025-02-27],
        invoice_due: ~D[2025-02-27],
        project_description: "some updated project_description",
        invoice_state: "some updated invoice_state"
      }

      assert {:ok, %Invoice{} = invoice} = Records.update_invoice(invoice, update_attrs)
      assert invoice.to_address == "some updated to_address"
      assert invoice.from_address == "some updated from_address"
      assert invoice.from_city == "some updated from_city"
      assert invoice.from_post_code == "some updated from_post_code"
      assert invoice.from_country == "some updated from_country"
      assert invoice.to_client_name == "some updated to_client_name"
      assert invoice.to_client_email == "some updated to_client_email"
      assert invoice.to_city == "some updated to_city"
      assert invoice.to_post_code == "some updated to_post_code"
      assert invoice.to_country == "some updated to_country"
      assert invoice.invoice_date == ~D[2025-02-27]
      assert invoice.invoice_due == ~D[2025-02-27]
      assert invoice.project_description == "some updated project_description"
      assert invoice.invoice_state == "some updated invoice_state"
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()
      assert {:error, %Ecto.Changeset{}} = Records.update_invoice(invoice, @invalid_attrs)
      assert invoice == Records.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Records.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Records.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Records.change_invoice(invoice)
    end
  end
end
