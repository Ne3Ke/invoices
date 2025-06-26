defmodule InvoiceGenerator.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notifications" do
    field :user_id, :binary_id
    field :product_updates, :boolean, default: false
    field :sign_in_notification, :boolean, default: false
    field :payment_reminders, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:product_updates, :sign_in_notification, :payment_reminders])
    |> validate_required([:product_updates, :sign_in_notification, :payment_reminders])
    |> unique_constraint(:user_id)
  end
end
