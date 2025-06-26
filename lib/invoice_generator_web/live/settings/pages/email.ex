defmodule InvoiceGeneratorWeb.SettingsLive.EmailNotifications do
  alias InvoiceGenerator.Notifications.Notification
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.{Helpers, Repo, Notifications}

  alias InvoiceGenerator.Notifications.Notification

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      {live_render(@socket, InvoiceGeneratorWeb.Header,
        session: %{
          "user" => "user?email=#{@current_user.email}"
        },
        id: "live_header",
        sticky: true
      )}

      <div class="min-h-screen mx-6 sm:ml-32 sm:mr-10 sm:py-6">
        {live_render(@socket, InvoiceGeneratorWeb.Settings.LiveDrawer,
          session: %{
            "active_tab" => "notifications",
            "user" => "user?email=#{@current_user.email}"
          },
          id: "settings_live_drawer",
          sticky: true
        )}

        <div class="border border-blue-400 mx-4 py-20">
          <Layout.flex flex_direction="col" align_items="start" class="gap-4 border border-red-400">
            <div class="border border-red-400">
              <.live_component
                module={InvoiceGeneratorWeb.Profile.ActualPicture}
                id="actual_picture_live_component"
                profile_url={@profile_url}
                name={@current_user.name}
              />
            </div>
          </Layout.flex>

          <Text.title class="my-4">
            Edit Notifications Preferences
          </Text.title>

          <div>
            <.form for={@form} phx-submit="change_notifications">
              <.input
                field={@form[:product_updates]}
                type="checkbox"
                label="Newsletter and product updates"
              />
              <.input
                field={@form[:sign_in_notification]}
                type="checkbox"
                label="Sign in notification"
              />
              <.input field={@form[:payment_reminders]} type="checkbox" label="Due payment reminders" />

              <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Saving...">
                Save Changes
              </Button.button>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    user_id = user.id

    profile_url = Helpers.get_profile_url(user_id)

    {notification, notification_changeset} = get_form_source(user_id)

    form = to_form(notification_changeset, as: "notifications")

    {:ok,
     socket
     |> assign(profile_url: profile_url)
     |> assign(form: form)
     |> assign(notification_settings: notification)}
  end

  defp get_form_source(user_id) do
    case Notifications.get_notification_by_user_id(user_id) do
      nil ->
        notification = %Notification{user_id: user_id, product_updates: true}

        changeset = Notifications.change_notification(notification)

        {notification, changeset}

      user_notification_settings ->
        changeset = Notifications.change_notification(user_notification_settings)

        {user_notification_settings, changeset}
    end
  end

  @impl true
  def handle_event("change_notifications", %{"notifications" => notification_params}, socket) do
    user_id = socket.assigns.current_user.id

    notification_settings = socket.assigns.notification_settings

    changeset = Notifications.change_notification(notification_settings, notification_params)

    case submit_details(user_id, changeset) do
      :success ->
        {:noreply,
         socket
         |> put_flash(:info, "Your notification settings were updated successfully")}

      :failure ->
        {:noreply,
         socket
         |> put_flash(:error, "An error occurred while updating your notification settings")}
    end
  end

  defp submit_details(user_id, changeset) do
    case Notifications.get_notification_by_user_id(user_id) do
      nil ->
        case Repo.insert(changeset) do
          {:ok, _notification} ->
            :success

          {:error, _changeset} ->
            :failure
        end

      _user_notification_settings ->
        case Repo.update(changeset) do
          {:ok, _updated_record} ->
            :success

          {:error, _changeset} ->
            :failure
        end
    end
  end
end
