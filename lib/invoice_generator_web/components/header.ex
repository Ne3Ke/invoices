defmodule InvoiceGeneratorWeb.Header do
  @moduledoc """
  Renders the header as a child liveview
  """
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.Accounts

  alias InvoiceGenerator.Helpers

  @impl true
  def mount(_params, session, socket) do
    %{"user" => "user?email=" <> email} = session

    current_user = Accounts.get_user_by_email(email)

    user_id = current_user.id
    profile_url = Helpers.get_profile_url(user_id)

    socket =
      socket
      |> assign(:profile_url, profile_url)
      |> assign(:theme, "profile_url")
      |> assign(is_dark: false)

    {:ok, socket, layout: false}
  end

  @impl true
  def handle_event("dark-mode", %{"dark" => value}, socket) do
    is_dark = change_theme(value)

    socket =
      socket
      |> assign(is_dark: is_dark)

    {:noreply, push_event(socket, "toggle-mode", %{})}
  end

  defp change_theme(value) do
    if value == false do
      true
    else
      false
    end
  end

  defp theme_icon(is_dark) do
    if is_dark == false do
      ~p"/images/header/moon.svg"
    else
      ~p"/images/header/light.svg"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="w-24 h-screen fixed top-0 left-0 bg-[#373B53] text-white rounded-r-3xl hidden sm:block">
        <div class="flex flex-col gap-[30rem]">
          <section>
            <.link>
              <img src={~p"/images/header/logo.svg"} alt="home" class="w-full h-full" />
            </.link>
          </section>
          <section class="flex flex-col gap-6 items-center">
            <div>
              <.link phx-click={JS.push("dark-mode", value: %{dark: @is_dark})}>
                <img src={theme_icon(@is_dark)} alt="theme" />
              </.link>
            </div>
            <div>
              <img src={@profile_url} class="h-12 w-12 rounded-full object-cover object-center" />
            </div>
          </section>
        </div>
      </div>

      <div class="border border-red-400 bg-[#252945] sm:hidden">
        <Layout.flex class="gap-6">
          <Layout.flex>
            <section>
              <.link>
                <img src={~p"/images/header/logo.svg"} alt="home" />
              </.link>
            </section>
            <section>
              <.link phx-click={JS.push("dark-mode", value: %{dark: @is_dark})}>
                <img src={theme_icon(@is_dark)} alt="theme" />
              </.link>
            </section>
          </Layout.flex>
          <section class="w-[30%] border border-red-400">
            <div class="w-[60%] mx-auto rounded-full overflow-hidden">
              <img src={@profile_url} class="h-10 w-10 rounded-full object-cover object-center" />
            </div>
          </section>
        </Layout.flex>
      </div>
    </div>
    """
  end
end
