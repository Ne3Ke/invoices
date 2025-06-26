defmodule InvoiceGenerator.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceGenerator.Notifications` context.
  """

  @doc """
  Generate a notification.
  """
  def notification_fixture(attrs \\ %{}) do
    {:ok, notification} =
      attrs
      |> Enum.into(%{
        payment_reminders: true,
        product_updates: true,
        sign_in_notification: true
      })
      |> InvoiceGenerator.Notifications.create_notification()

    notification
  end
end
