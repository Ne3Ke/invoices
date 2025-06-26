defmodule InvoiceGeneratorWeb.Settings.LiveDrawer do
  @moduledoc """
  Renders a navigation drawer as a child liveview
  """
  use InvoiceGeneratorWeb, :live_view
  alias InvoiceGeneratorWeb.Settings.NavigationComponent

  alias InvoiceGenerator.Accounts

  @impl true
  def mount(_params, session, socket) do
    %{"active_tab" => active_tab, "user" => "user?email=" <> email} = session
    current_user = Accounts.get_user_by_email(email)

    socket =
      socket
      |> assign(:current_user, current_user)

    {:ok,
     socket
     |> assign(:active_tab, active_tab), layout: false}
  end

  @impl true
  @spec handle_event(<<_::40, _::_*88>>, map(), any()) :: {:noreply, any()}
  def handle_event("on_live_navigate", %{"active_tab" => active_tab} = _params, socket) do
    {:noreply, socket |> assign(:active_tab, active_tab)}
  end

  @impl true
  def handle_info(%{event: "on_live_navigate", active_tab: active_tab} = _params, socket) do
    {:noreply, socket |> assign(:active_tab, active_tab)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <NavigationComponent.drawer active_tab={@active_tab} user={@current_user} />
    """
  end
end
