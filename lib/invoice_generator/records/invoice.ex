defmodule InvoiceGenerator.Records.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "invoices" do
    field :user_id, :binary_id
    field :to_address, :string
    field :from_address, :string
    field :from_city, :string
    field :from_post_code, :string
    field :from_country, :string
    field :to_client_name, :string
    field :to_client_email, :string
    field :to_city, :string
    field :to_post_code, :string
    field :to_country, :string
    field :invoice_date, :date
    field :invoice_due_days, :string, virtual: true
    field :invoice_due, :date
    field :project_description, :string
    field :invoice_state, Ecto.Enum, values: [:Pending, :Draft, :Paid]

    timestamps(type: :utc_datetime)

    embeds_many :items, InvoiceGenerator.Records.Item, on_replace: :delete
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :user_id,
      :from_address,
      :from_city,
      :from_post_code,
      :from_country,
      :to_client_name,
      :to_client_email,
      :to_address,
      :to_city,
      :to_post_code,
      :to_country,
      :invoice_date,
      :invoice_due,
      :project_description,
      :invoice_state
    ])
    |> validate_required([
      :user_id,
      :from_address,
      :from_city,
      :from_post_code,
      :from_country,
      :to_client_name,
      :to_client_email,
      :to_address,
      :to_city,
      :to_post_code,
      :to_country,
      :invoice_date,
      :invoice_due,
      :project_description,
      :invoice_state
    ])
    |> validate_client_email()
    |> cast_embed(:items)
    |> validate_length(:project_description,
      min: 10,
      max: 100,
      message: "The description must range between 10 and 100 characters in length"
    )
  end

  @doc false
  def details_changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :from_address,
      :from_city,
      :from_post_code,
      :from_country,
      :to_client_name,
      :to_client_email,
      :to_address,
      :to_city,
      :to_post_code,
      :to_country
    ])
    |> validate_required([
      :from_address,
      :from_city,
      :from_post_code,
      :from_country,
      :to_client_name,
      :to_client_email,
      :to_address,
      :to_city,
      :to_post_code,
      :to_country
    ])
    |> validate_client_email()
  end

  defp validate_client_email(changeset) do
    changeset
    |> validate_required([:to_client_email])
    |> validate_format(:to_client_email, ~r/^[^\s]+@[^\s]+$/,
      message: "must have the @ sign and no spaces"
    )
    |> validate_length(:to_client_email, max: 160)
  end
end
