defmodule InvoiceGeneratorWeb.InvoiceLive.FilterComponent do
  use InvoiceGeneratorWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Menu.menu
        id="menu-single-default"
        class="relative inline-block text-left w-56"
        menu_btn_class="inline-flex justify-center rounded-md px-4 py-3 text-sm font-medium text-white focus:outline-none focus-visible:ring-2 focus-visible:ring-white/75"
        menu_items_class="left-0 px-1 py-1 mt-2 w-56 origin-top-left space-y-0.5 divide-y divide-gray-100 rounded-md bg-white shadow-lg ring-1 ring-black/5 focus:outline-none"
        menu_item_class="focus:border-none focus:border-transparent focus:outline-none focus:text-white  focus:rounded-md hover:rounded-md transform-all hover:border-transparent text-gray-700 duration-100 hover:bg-purple-100 hover:text-gray-800 "
      >
        <:button>
          <Layout.flex
            flex_direction="row"
            justify_content="center"
            align_items="center"
            class="gap-3"
          >
            <div class="text-black">Filter</div>
            <div>
              <img src={~p"/images/invoices/downarrow.svg"} alt="Down Arrow" />
            </div>
          </Layout.flex>
        </:button>
        <:item>
          <button
            class="px-2 py-2 space-x-4 inline-flex items-center"
            phx-click={JS.push("invoice_state", value: %{state: "Draft"})}
            phx-target={@myself}
          >
            <label class="container league-spartan-bold">Draft <input type="radio" name="radio" />
              <span class="checkmark"></span></label>
          </button>
        </:item>
        <:item>
          <button
            class="px-2 py-2 space-x-4 inline-flex items-center"
            phx-click={JS.push("invoice_state", value: %{state: "Pending"})}
            phx-target={@myself}
          >
            <label class="container league-spartan-bold">
              Pending <input type="radio" checked="checked" name="radio" />
              <span class="checkmark"></span>
            </label>
          </button>
        </:item>

        <:item>
          <button
            class="px-2 py-2 space-x-4 inline-flex items-center"
            phx-click={JS.push("invoice_state", value: %{state: "Paid"})}
            phx-target={@myself}
          >
            <label class="container league-spartan-bold">Paid <input type="radio" name="radio" />
              <span class="checkmark"></span></label>
          </button>
        </:item>
      </Menu.menu>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def handle_event("invoice_state", %{"state" => state}, socket) do
    state = String.to_atom(state)
    send(self(), {:filter_invoice, state})

    {:noreply, socket}
  end
end
