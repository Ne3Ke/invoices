defmodule InvoiceGeneratorWeb.SettingsLive.BusinessAddressDetails do
  alias InvoiceGenerator.{Helpers, Profile, Repo}

  alias InvoiceGenerator.Profile.UserProfile

  use InvoiceGeneratorWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <Layout.col class="space-y-1.5">
          <label for="profile_country">
            <Text.text class="text-tremor-content">
              Country
            </Text.text>
          </label>

          <Select.search_select
            id="profile_country"
            name={@form[:country].name}
            placeholder="Select..."
            value={@form[:country].value}
            phx-update="ignore"
            required="true"
          >
            <:item :for={name <- @countries}>
              {name}
            </:item>
          </Select.search_select>
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <label>
            <Text.text class="text-tremor-content text-bold py-2">
              City
            </Text.text>
          </label>

          <.input field={@form[:city]} type="text" placeholder="Street Address" />
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <label>
            <Text.text class="text-tremor-content text-bold py-2">
              Street Address
            </Text.text>
          </label>

          <.input field={@form[:street]} type="text" placeholder="Street Address" />
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <label>
            <Text.text class="text-tremor-content text-bold py-2">
              Postal Code
            </Text.text>
          </label>

          <.input field={@form[:postal_code]} type="text" placeholder="Postal Code" />
        </Layout.col>

        <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Saving...">
          Save Changes
        </Button.button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    user_id = assigns.current_user

    countries = Helpers.countries()

    socket =
      socket
      |> assign(countries: countries)

    case Helpers.get_user(user_id) do
      nil ->
        user_profile = %UserProfile{user_id: user_id}

        form = to_form(Profile.change_user_profile(user_profile))

        {:ok,
         socket
         |> assign(form: form)
         |> assign(userprofile: user_profile)}

      user_profile ->
        form = to_form(Profile.change_user_profile(user_profile))

        {:ok,
         socket
         |> assign(form: form)
         |> assign(userprofile: user_profile)}
    end
  end

  @impl true
  def handle_event("validate", %{"user_profile" => user_profile_params}, socket) do
    changeset = Profile.change_user_profile(socket.assigns.userprofile, user_profile_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"user_profile" => user_profile_params}, socket) do
    changeset = Profile.change_user_profile(socket.assigns.userprofile, user_profile_params)

    case changeset.valid? do
      true ->
        send(self(), :update_personal_info)
        Repo.update(changeset)

        {:noreply, socket}

      false ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end
end
