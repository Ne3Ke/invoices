defmodule InvoiceGenerator.Records do
  @moduledoc """
  The Records context.
  """

  import Ecto.Query, warn: false
  alias InvoiceGenerator.Repo

  alias InvoiceGenerator.Records.{Invoice, Item}

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices do
    Repo.all(Invoice)
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id), do: Repo.get!(Invoice, id)

  def get_invoices_by_user_id(user_id) do
    query = from i in Invoice, where: i.user_id == ^user_id

    Repo.all(query)
  end

  def get_invoices_by_invoice_state(user_id, state) do
    query = from i in Invoice, where: i.user_id == ^user_id and i.invoice_state == ^state

    Repo.all(query)
  end

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(%{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invoice.

  ## Examples

      iex> delete_invoice(invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{data: %Invoice{}}

  """
  def change_invoice(%Invoice{} = invoice, attrs \\ %{}) do
    Invoice.changeset(invoice, attrs)
  end

  def change_invoice_details(%Invoice{} = invoice, attrs \\ %{}) do
    Invoice.details_changeset(invoice, attrs)
  end

  # * Producing a changeset for our items

  def change_invoice_items(%Item{} = invoice_item, attrs \\ %{}) do
    Item.changeset(invoice_item, attrs)
  end
end
