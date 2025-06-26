defmodule InvoiceGeneratorWeb.Event.Step do
  @moduledoc """

  Describe a step in the multi-step form and where it can go.
  """

  defstruct [:name, :prev, :next]
end

defmodule InvoiceGeneratorWeb.UserProfileLive.Index do
  require Logger
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.Profile
  alias InvoiceGenerator.Profile.UserProfile
  alias SimpleS3Upload
  # alias ExAwsS3

  alias InvoiceGenerator.Profile.Picture

  alias InvoiceGenerator.Repo

  alias InvoiceGeneratorWeb.Event.Step

  @steps [
    %Step{name: "picture", prev: nil, next: "details"},
    %Step{name: "details", prev: "picture", next: nil}
  ]

  @impl true

  def render(assigns) do
    ~H"""
    <div>
      <div class={unless @progress.name == "picture", do: "hidden"}>
        <form id="upload-form" phx-submit="save" phx-change="validate">
          <fieldset>
            <.live_file_input type="file" upload={@uploads.photo} class="hidden pointer-events-none" />
          </fieldset>

          <.droptarget
            for={@uploads.photo.ref}
            on_click={JS.dispatch("click", to: "##{@uploads.photo.ref}", bubbles: false)}
            drop_target_ref={@uploads.photo.ref}
          />

          <%= for entry <- @uploads.photo.entries
                 do %>
            <article class="upload-entry">
              <figure>
                <.live_img_preview entry={entry} height="40" />
              </figure>

              <Layout.flex justify_content="start" align_items="center" class="space-x-4">
                <Layout.flex
                  justify_content="center"
                  class="w-16 h-16 bg-tremor-brand text-white rounded-md flex-shrink-0"
                >
                  <.icon name="hero-camera" class="h-6 w-6" />
                </Layout.flex>

                <Layout.flex flex_direction="col" align_items="start">
                  <Layout.flex class="space-x-4">
                    <Layout.flex class="" flex_direction="col" align_items="start">
                      <div class="w-full flex-1">
                        <Text.subtitle color="black" class="text-ellipsis">
                          {entry.client_name}
                        </Text.subtitle>
                      </div>
                    </Layout.flex>

                    <Button.button
                      class="mt-2 flex-shrink-0"
                      variant="secondary"
                      color="rose"
                      size="xs"
                      phx-click="cancel-upload"
                      phx-value-ref={entry.ref}
                      aria-label="cancel"
                    >
                      Cancel
                    </Button.button>
                  </Layout.flex>

                  <Bar.progress_bar
                    :if={entry.progress > 0}
                    class="mt-3"
                    value={entry.progress}
                    show_animation={true}
                  />
                </Layout.flex>
              </Layout.flex>

              <%= for err <- upload_errors(@uploads.photo, entry) do %>
                <p class="alert alert-danger">{error_to_string(err)}</p>
              <% end %>
            </article>
          <% end %>

          <Button.button size="xl" type="submit" class="mb-10">
            Continue
          </Button.button>
        </form>
      </div>

      <div class={unless @progress.name == "details", do: "hidden"}>
        <.live_component
          module={InvoiceGeneratorWeb.Profile.Address.Component}
          id="user_details"
          current_user={@current_user.id}
          user_profile={@user_profile}
        />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # * The presign_upload function generates metadata
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:photo,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        id: "profile_image_file",
        max_file_size: 80_000_000,
        external: fn entry, socket ->
          SimpleS3Upload.presign_upload(entry, socket, "photo")
        end
      )

    first_step = Enum.at(@steps, 0)

    user_id = socket.assigns.current_user.id

    user_profile = %UserProfile{user_id: user_id}

    socket =
      socket
      |> assign(live_action: :new)
      |> assign(progress: first_step)
      |> assign(user_profile: user_profile)

    {:ok, socket}
  end

  defp submit_details(socket, changeset) do
    details = socket.assigns.details

    address_details = changeset.changes

    complete_details =
      Map.merge(address_details, %{picture: details})

    complete_profile = Profile.change_user_profile(socket.assigns.user_profile, complete_details)

    Repo.insert(complete_profile)
  end

  @impl true
  def handle_info({:picture_details, details}, socket) do
    Logger.warning("Picture details are in the socket :)")

    if details == %{} do
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> assign(details: details)}
    end
  end

  @impl true
  def handle_info({:valid_details, changeset}, socket) do
    case submit_details(socket, changeset) do
      {:ok, _record} ->
        {:noreply,
         socket
         |> put_flash(:info, "User profile created successfully")
         |> redirect(to: ~p"/home")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "You have already completed your profile!")
         |> redirect(to: ~p"/home")}
    end
  end

  @impl true
  def handle_info(:back, socket) do
    first_step = Enum.at(@steps, 0)

    IO.puts("going back")

    {:noreply,
     socket
     |> assign(progress: first_step)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    second_step = Enum.at(@steps, 1)
    entries = socket.assigns.uploads.photo.entries

    case Enum.count(entries) do
      0 ->
        picture_details = %{}
        # if no entries exist send an empty map
        send(self(), {:picture_details, picture_details})

        {:noreply,
         socket
         |> assign(progress: second_step)}

      _ ->
        case Map.get(socket.assigns, :details) do
          nil ->
            # if nothing was uploaded earlier just consume the current uploads
            consume_entries(socket)

          previous_file_details ->
            file_name = "photo/" <> previous_file_details.original_filename

            # if there was an earlier upload then delete it before consuming the current one

            _result =
              ExAws.S3.delete_object("invoicegenerator", file_name)
              |> ExAws.request()

            consume_entries(socket)
        end

        # * consume_uploaded_entries ends here !! and at
        # * this point the picture has been uploaded to s3
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref, "value" => _value}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  @impl true
  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp consume_entries(socket) do
    second_step = Enum.at(@steps, 1)

    _uploaded_files =
      consume_uploaded_entries(socket, :photo, fn _meta, entry ->
        client_name = Map.get(entry, :client_name)
        filename = Map.get(entry, :uuid) <> "." <> SimpleS3Upload.ext(entry)

        picture_details = %{filename: filename, original_filename: client_name}

        send(self(), {:picture_details, picture_details})

        {:ok,
         %Picture{
           filename: filename,
           original_filename: client_name
         }}
      end)

    {:noreply,
     socket
     |> assign(progress: second_step)}
  end

  attr :on_click, JS, required: true
  attr :drop_target_ref, :string, required: true
  attr :for, :string, required: true

  @doc """
  Renders a drop target to upload files
  """

  def droptarget(assigns) do
    ~H"""
    <div
      phx-click={@on_click}
      phx-drop-target={@drop_target_ref}
      for={@for}
      class="flex flex-col items-center max-w-2xl w-full py-8 px-6 mx-auto mt-2 text-center border-2 border-gray-300 border-dashed cursor-pointer dark:bg-gray-900 dark:border-gray-700 rounded-md"
    >
      <.icon name="hero-camera" class="w-8 h-8 mb-4 text-gray-500 dark:text-gray-400" />
      <Text.title>
        Take Your Photo
      </Text.title>
    </div>
    """
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:external_client_failure), do: "External client failure "
end
