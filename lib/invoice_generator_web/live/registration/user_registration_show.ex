defmodule InvoiceGeneratorWeb.UserRegistrationLive.Show do
  use InvoiceGeneratorWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      nothing really
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    dbg(id)
    {:noreply, socket}
  end
end
