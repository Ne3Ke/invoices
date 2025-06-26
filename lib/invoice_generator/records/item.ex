defmodule InvoiceGenerator.Records.Item do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
    field(:quantity, :integer)
    field(:price, :integer)
    field(:total, :integer)
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:name, :quantity, :price, :total])
    |> validate_required([:name, :quantity, :price, :total])
  end
end
