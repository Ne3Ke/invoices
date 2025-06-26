defmodule InvoiceGenerator.Profile.UserProfile do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "profiles" do
    field :user_id, :binary_id
    field :country, :string
    field :city, :string
    field :phone, :string
    field :postal_code, :string
    field :street, :string

    timestamps(type: :utc_datetime)
    embeds_one :picture, InvoiceGenerator.Profile.Picture, on_replace: :update
  end

  @doc false
  def changeset(user_profile, attrs) do
    user_profile
    |> cast(attrs, [:user_id, :country, :city, :phone, :postal_code, :street])
    |> validate_required([:user_id, :country, :city, :phone, :postal_code, :street])
    # * ensure unique constraint of user_id
    |> unique_constraint(:user_id)
    |> validate_the_lengths()
    |> cast_embed(:picture)
  end

  @spec validate_the_lengths(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_the_lengths(changeset) do
    changeset
    |> validate_length(:country,
      min: 3,
      max: 40,
      message: "the country must be between 3 and 40 characters"
    )
    |> validate_length(:city,
      min: 3,
      max: 40,
      message: "the city must be between 3 and 40 characters"
    )
    |> validate_length(:phone,
      min: 3,
      max: 15,
      message: "the phone must be between 3 and 15 characters"
    )
    |> validate_length(:postal_code,
      min: 3,
      max: 15,
      message: "the country must be between 3 and 15 characters"
    )
  end
end
