defmodule InvoiceGeneratorWeb.Profile.Address.Component do
  use InvoiceGeneratorWeb, :live_component

  alias InvoiceGenerator.Profile

  alias InvoiceGenerator.Helpers

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="user_profile-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <Layout.col class="space-y-1.5">
          <Select.search_select
            id="country_id"
            name={@form[:country].name}
            placeholder="Choose Country"
            value={@form[:country].value}
            phx-update="ignore"
          >
            <:item :for={name <- @countries}>
              {name}
            </:item>
          </Select.search_select>
        </Layout.col>
        <Layout.col class="space-y-1.5">
          <.input field={@form[:city]} type="text" placeholder="City Name" />
        </Layout.col>
        <Layout.col class="space-y-1.5">
          <.input field={@form[:street]} type="text" placeholder="Street Address" />
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <.input field={@form[:postal_code]} type="text" placeholder="Postal Code" />
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <.input field={@form[:phone]} type="text" placeholder="Phone Number" />
        </Layout.col>

        <Button.button>
          <.link phx-click={JS.push("back")} phx-target={@myself}>
            Back
          </.link>
        </Button.button>

        <Button.button type="submit" phx-disable-with="Saving...">
          Complete
        </Button.button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_profile: user_profile} = assigns, socket) do
    countries = Helpers.countries()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:countries, countries)
     |> assign_new(:form, fn ->
       to_form(Profile.change_user_profile(user_profile))
     end)}
  end

  @impl true
  def handle_event("validate", %{"user_profile" => user_profile_params}, socket) do
    changeset = Profile.change_user_profile(socket.assigns.user_profile, user_profile_params)

    case changeset.valid? do
      true ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}

      false ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  @impl true
  def handle_event("back", _params, socket) do
    send(self(), :back)
    {:noreply, socket}
  end

  def handle_event("save", %{"user_profile" => user_profile_params}, socket) do
    changeset = Profile.change_user_profile(socket.assigns.user_profile, user_profile_params)

    case changeset.valid? do
      true ->
        send(self(), {:valid_details, changeset})

        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}

      false ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end

    # save_user_profile(socket, socket.assigns.action, user_profile_params)
  end

  # defp save_user_profile(socket, :edit, user_profile_params) do
  #   case Profile.update_user_profile(socket.assigns.user_profile, user_profile_params) do
  #     {:ok, _user_profile} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "User profile updated successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, form: to_form(changeset))}
  #   end
  # end

  # defp save_user_profile(socket, :new, user_profile_params) do
  #   case Profile.create_user_profile(user_profile_params) do
  #     {:ok, _user_profile} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "User profile created successfully")
  #        |> redirect(to: ~p"/welcome")}

  #     {:error, _changeset} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:error, "User profile exists Already")
  #        |> redirect(to: ~p"/welcome")}
  #   end
  # end
end
