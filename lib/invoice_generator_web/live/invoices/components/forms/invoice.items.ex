defmodule InvoiceGeneratorWeb.InvoiceLive.ItemComponent do
  use InvoiceGeneratorWeb, :live_component

  alias InvoiceGenerator.{Helpers}

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <p class="text-red-400">{@item_error}</p>
        <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
          <div>
            <%= for item <- @items do %>
              <div class={show_errors_on_item_field(item.id, @list_of_submitted_params)}>
                <p class="text-red-400">This item field contains errors</p>
              </div>
              <Layout.col class="space-y-1.5">
                <label for="name_field">
                  <Text.text class="text-tremor-content">
                    Item Name
                  </Text.text>
                </label>

                <.input field={@form[item.name]} type="text" placeholder="Item Name..." />
              </Layout.col>

              <Layout.col class="space-y-1.5">
                <label for="name_field">
                  <Text.text class="text-tremor-content">
                    Quantity
                  </Text.text>
                </label>

                <.input field={@form[item.quantity]} type="number" placeholder="Quantity..." />
              </Layout.col>

              <Layout.col class="space-y-1.5">
                <label for="name_field">
                  <Text.text class="text-tremor-content">
                    Price
                  </Text.text>
                </label>

                <.input field={@form[item.price]} type="number" placeholder="Price..." />
              </Layout.col>

              <Layout.col class="space-y-1.5">
                <label for="name_field">
                  <Text.text class="text-tremor-content">
                    Total
                  </Text.text>
                </label>

                <.input field={@form[item.total]} type="text" readonly placeholder="Total..." />
              </Layout.col>

              <div class={show_remove_item_button(item.id, @item_count)}>
                <button
                  type="button"
                  class="bg-[#FFFFFF] text-[#7E88C3] rounded-full px-5 py-3"
                  phx-click={JS.push("remove_item", value: %{id: item.id})}
                  phx-target={@myself}
                >
                  <img src={~p"/images/invoices/bin.svg"} alt="Bin" />
                </button>
              </div>
            <% end %>
          </div>

          <button
            type="button"
            class="w-full league-spartan-bold bg-[#F9FAFE] text-[#7E88C3] rounded-full px-5 py-3 mt-8"
            phx-click={JS.push("add_new_item")}
            phx-target={@myself}
          >
            Add new item
          </button>
          <div class={["flex gap-4 mt-8", determine_justification(@action)]}>
            <button
              type="button"
              class="league-spartan-bold bg-[#F9FAFE] text-[#7E88C3] rounded-full px-5 py-3"
              phx-click={JS.push("close_modal")}
              phx-target={@myself}
            >
              <%= if @action == :edit do %>
                Cancel
              <% else %>
                Discard
              <% end %>
            </button>

            <div class="flex gap-4">
              <%= if @action == :new do %>
                <button
                  type="submit"
                  class="league-spartan-bold bg-[#373B53] text-[#FFFFFF] rounded-full px-5 py-3"
                  phx-click={JS.push("save", value: %{status: "Draft"})}
                  phx-target={@myself}
                  phx-disable-with="Saving..."
                >
                  Save as Draft
                </button>
              <% end %>

              <button
                type="submit"
                class="league-spartan-bold bg-[#7C5DFA] text-[#FFFFFF] rounded-full px-5 py-3"
                phx-click={JS.push("save", value: %{status: "Pending"})}
                phx-target={@myself}
                phx-disable-with="Saving..."
              >
                <%= if @action == :edit do %>
                  Save Changes
                <% else %>
                  Save & Send
                <% end %>
              </button>
            </div>
          </div>
        </.form>
      </Layout.col>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:items, [])
     |> assign(item_count: 0)
     |> assign(list_of_submitted_params: [])
     |> assign(item_error: "")
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"items" => item_params}, socket) do
    # * the main purpose of whatever is here is to offer feedback to the user
    item_count = socket.assigns.item_count

    item_params = remove_unused_fields(item_params)

    item_params = Helpers.get_totals(item_params, item_count)

    form = to_form(item_params, as: "items")

    {:noreply,
     socket
     |> assign(form: form)
     |> assign(item_error: "")}
  end

  def handle_event("save", %{"status" => value}, socket) do
    params = socket.assigns.form.params

    case params == %{} do
      true ->
        {:noreply,
         socket
         |> assign(item_error: "Please add at least one item!")}

      false ->
        count = socket.assigns.item_count
        list_of_item_params = Helpers.get_list_of_params(params, count)

        case Enum.find(list_of_item_params, fn x -> x.errors == true end) do
          nil ->
            status = String.to_atom(value)
            action = socket.assigns.action
            send(self(), {:valid_item_details, list_of_item_params, status, action})

            {:noreply,
             socket
             |> assign(list_of_submitted_params: [])}

          _map ->
            {:noreply,
             socket
             |> assign(list_of_submitted_params: list_of_item_params)}
        end
    end
  end

  @impl true
  def handle_event("add_new_item", _params, socket) do
    items = socket.assigns.items

    count = socket.assigns.item_count

    new_count = count + 1

    name = "product_" <> Integer.to_string(new_count) <> "_name"
    quantity = "product_" <> Integer.to_string(new_count) <> "_quantity"
    price = "product_" <> Integer.to_string(new_count) <> "_price"
    total = "product_" <> Integer.to_string(new_count) <> "_total"

    new_item = %{
      id: new_count,
      name: String.to_atom(name),
      quantity: String.to_atom(quantity),
      price: String.to_atom(price),
      total: String.to_atom(total)
    }

    # to append the new_item into our list
    new_items = items ++ [new_item]

    {
      :noreply,
      socket
      |> assign(item_count: new_count)
      |> assign(:items, new_items)
    }
  end

  @impl true
  def handle_event("remove_item", %{"id" => id}, socket) do
    items = socket.assigns.items

    count = socket.assigns.item_count

    new_count = count - 1

    item =
      Enum.filter(items, fn x -> x.id == id end)
      |> Enum.at(0)

    new_items =
      Enum.filter(items, fn x -> x != item end)

    {:noreply,
     socket
     |> assign(item_count: new_count)
     |> assign(items: new_items)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket
     |> push_patch(to: socket.assigns.patch)}
  end

  defp assign_form(socket) do
    form = to_form(%{}, as: "items")

    assign(socket, :form, form)
  end

  defp remove_unused_fields(params) do
    map_of_products =
      Enum.reduce(params, %{}, fn {key, value}, accumulator_map ->
        case String.starts_with?(key, "_unused") do
          true ->
            accumulator_map

          false ->
            Map.put(accumulator_map, key, value)
        end
      end)

    map_of_products
  end

  defp show_remove_item_button(id, count) do
    if id == count do
      "block"
    else
      "hidden"
    end
  end

  defp show_errors_on_item_field(id, list_of_params) do
    item_index = id - 1

    if list_of_params == [] do
      "hidden"
    else
      case Enum.at(list_of_params, item_index) do
        nil ->
          "hidden"

        item_map ->
          if item_map.errors == true do
            "block"
          else
            "hidden"
          end
      end
    end
  end

  defp determine_justification(action) do
    case action == :new do
      true ->
        "justify-between"

      false ->
        "justify-end"
    end
  end
end
