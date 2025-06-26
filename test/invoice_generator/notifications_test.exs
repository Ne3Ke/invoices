defmodule InvoiceGenerator.NotificationsTest do
  use InvoiceGenerator.DataCase

  alias InvoiceGenerator.Notifications

  describe "notifications" do
    alias InvoiceGenerator.Notifications.Notification

    import InvoiceGenerator.NotificationsFixtures

    @invalid_attrs %{product_updates: nil, sign_in_notification: nil, payment_reminders: nil}

    test "list_notifications/0 returns all notifications" do
      notification = notification_fixture()
      assert Notifications.list_notifications() == [notification]
    end

    test "get_notification!/1 returns the notification with given id" do
      notification = notification_fixture()
      assert Notifications.get_notification!(notification.id) == notification
    end

    test "create_notification/1 with valid data creates a notification" do
      valid_attrs = %{product_updates: true, sign_in_notification: true, payment_reminders: true}

      assert {:ok, %Notification{} = notification} =
               Notifications.create_notification(valid_attrs)

      assert notification.product_updates == true
      assert notification.sign_in_notification == true
      assert notification.payment_reminders == true
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification(@invalid_attrs)
    end

    test "update_notification/2 with valid data updates the notification" do
      notification = notification_fixture()

      update_attrs = %{
        product_updates: false,
        sign_in_notification: false,
        payment_reminders: false
      }

      assert {:ok, %Notification{} = notification} =
               Notifications.update_notification(notification, update_attrs)

      assert notification.product_updates == false
      assert notification.sign_in_notification == false
      assert notification.payment_reminders == false
    end

    test "update_notification/2 with invalid data returns error changeset" do
      notification = notification_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_notification(notification, @invalid_attrs)

      assert notification == Notifications.get_notification!(notification.id)
    end

    test "delete_notification/1 deletes the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{}} = Notifications.delete_notification(notification)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_notification!(notification.id) end
    end

    test "change_notification/1 returns a notification changeset" do
      notification = notification_fixture()
      assert %Ecto.Changeset{} = Notifications.change_notification(notification)
    end
  end
end
