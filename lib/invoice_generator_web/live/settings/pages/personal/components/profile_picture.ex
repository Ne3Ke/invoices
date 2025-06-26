defmodule InvoiceGeneratorWeb.Profile.ActualPicture do
  use InvoiceGeneratorWeb, :live_component
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Layout.flex flex_direction="w-full row">
        <section class="h-20 w-20 rounded-full border-2 border-blue-400 overflow-hidden ">
          <img src={@profile_url} class="h-80 w-80 rounded-full object-cover object-center" />
        </section>
        <section>
          {@name} / Profile Information
        </section>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end

defmodule InvoiceGeneratorWeb.SettingsLive.UpdateProfilePicture do
  use InvoiceGeneratorWeb, :live_component
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <.form for={@form} phx-target={@myself} phx-change="check">
        <Button.button size="xl" class="bg-white hover:bg-white">
          <fieldset>
            <.live_file_input type="file" upload={@uploads.photo} class="hidden pointer-events-none" />
          </fieldset>

          <.droptarget
            for={@uploads.photo.ref}
            on_click={JS.dispatch("click", to: "##{@uploads.photo.ref}", bubbles: false)}
            drop_target_ref={@uploads.photo.ref}
          />
        </Button.button>

        <Button.button size="xl" class="mb-2">
          <.link
            phx-click={JS.push("delete", value: %{user_id: @user_id})}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </Button.button>
      </.form>
    </section>
    """
  end

  @impl true
  @spec update(maybe_improper_list() | map(), map()) :: {:ok, any()}
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:photo,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        id: "profile_image_file",
        max_file_size: 80_000_000,
        progress: &handle_progress/3,
        auto_upload: true,
        external: fn entry, socket ->
          SimpleS3Upload.presign_upload(entry, socket, "photo")
        end
      )

    form = to_form(%{})

    #  current_user = assigns
    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)}
  end

  defp handle_progress(:photo, entry, socket) do
    if entry.done? do
      _uploaded_file =
        consume_uploaded_entry(socket, entry, fn %{} = _meta ->
          filename = Map.get(entry, :uuid) <> "." <> SimpleS3Upload.ext(entry)
          original_filename = entry.client_name
          details = %{filename: filename, original_filename: original_filename}

          send(self(), {:update_profile_picture, details})

          {:ok, entry}
        end)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("check", _params, socket) do
    {:noreply, socket}
  end

  attr :on_click, JS, required: true
  attr :drop_target_ref, :string, required: true
  attr :for, :string, required: true

  @doc """
  Renders a drop target to upload files
  """

  def droptarget(assigns) do
    ~H"""
    <div phx-click={@on_click} phx-drop-target={@drop_target_ref} for={@for} class="bg-white">
      <Text.title>
        Upload a new photo
      </Text.title>
    </div>
    """
  end
end
