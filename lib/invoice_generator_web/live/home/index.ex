defmodule InvoiceGeneratorWeb.HomeLive.Index do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.Profile

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      {live_render(@socket, InvoiceGeneratorWeb.Header,
        session: %{
          "user" => "user?email=#{@current_user.email}"
        },
        id: "live_header",
        sticky: true
      )}

      <Layout.flex flex_direction="col" class="gap-32">
        <div class="flex w-[70%]  flex-col gap-3 items-center border-2 border-blue-400">
          <section class="h-36 w-36 rounded-full border-2 border-blue-400 overflow-hidden ">
            <img src={@profile_url} class="h-80 w-80 rounded-full object-cover object-center" />
          </section>
          <section>{@username}</section>
        </div>
        <Layout.flex flex_direction="col" class="w-[40%] md:w-[30%] gap-6 border border-red-400">
          <Layout.flex justify_content="start" class="gap-6 ">
            <div>
              <img src="images/home/home1.svg" />
            </div>
            <div>
              <.link navigate={~p"/invoices"}>
                Dashboard
              </.link>
            </div>
          </Layout.flex>

          <Layout.flex justify_content="start" class="gap-6">
            <div>
              <img src="images/home/home2.png" />
            </div>
            <div>
              <.link navigate={~p"/personaldetails"}>
                Settings
              </.link>
            </div>
          </Layout.flex>

          <Layout.flex justify_content="start" class="gap-6">
            <div>
              <img src="images/home/home3.svg" />
            </div>
            <div>
              <.link href={~p"/users/log_out"} method="delete">
                Sign out
              </.link>
            </div>
          </Layout.flex>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    username = socket.assigns.current_user.username
    user_id = socket.assigns.current_user.id

    case get_user(user_id) do
      nil ->
        {:ok,
         socket
         |> assign(profile_url: "")
         |> assign(username: username)}

      user ->
        base_url = "http://127.0.0.1:9000/invoicegenerator/photo/"

        user_profile_picture_url = base_url <> user.picture.original_filename

        {:ok,
         socket
         |> assign(profile_url: user_profile_picture_url)
         |> assign(username: username)}
    end
  end

  defp get_user(user_id) do
    Profile.get_user_profile_by_user_id(user_id)
  end
end
