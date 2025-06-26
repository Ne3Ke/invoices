defmodule InvoiceGenerator.Profile.Picture do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:original_filename, :string)
    field(:filename, :string)
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:original_filename, :filename])
    |> validate_required([:original_filename, :filename])
  end
end
