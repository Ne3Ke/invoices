defmodule InvoiceGeneratorWeb.Settings.NavigationComponent do
  alias Tremorx.Components.Layout
  alias Tremorx.Components.Text
  alias Tremorx.Theme

  use InvoiceGeneratorWeb, :html
  use Phoenix.Component

  attr :user, :any, required: true
  attr :active_tab, :any, required: true

  def drawer(assigns) do
    ~H"""
    <div class="pl-4">
      <Layout.flex flex_direction="col" align_items="start" class="gap-4">
        <Text.title color="black" class="font-bold">Settings</Text.title>
        <Layout.flex flex_direction="row" justify_content="start" class="w-[75%] gap-4">
          <.menu_item
            on_click={on_live_navigate(:personal, ~p"/personaldetails")}
            active={@active_tab == "personal"}
            name="Personal"
          />

          <.menu_item
            on_click={on_live_navigate(:password, ~p"/password")}
            active={@active_tab == "password"}
            name="Password"
          />

          <.menu_item
            on_click={on_live_navigate(:notifications, ~p"/emailnotifications")}
            active={@active_tab == "notifications"}
            name="Email notifications"
          />
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :active, :boolean, default: false
  attr :on_click, JS, default: nil
  attr :class, :string, default: nil

  @doc """
  Renders a menu item button in the drawer
  """
  def menu_item(assigns) do
    ~H"""
    <button
      phx-click={if(is_nil(@on_click) == false, do: @on_click, else: nil)}
      class={
        Tails.classes([
          Theme.make_class_name("menu_button", "root"),
          Theme.get_spacing_style("two_xs", "padding_x"),
          Theme.get_spacing_style("lg", "padding_y"),
          "flex-shrink-1 flex outline-none  rounded-tremor-default",
          if(@active,
            do: "text-[#7c5dfa]
            font-semibold",
            else: "hover:bg-gray-100 text-tremor-content
          dark:text-dark-tremor-content hover:text-tremor-content-emphasis"
          ),
          if(is_nil(@class) == false, do: @class, else: nil)
        ])
      }
    >
      <Layout.flex>
        <Layout.flex
          class={
            Tails.classes([
              "space-x-4"
            ])
          }
          justify_content="start"
        >
          <Text.subtitle class="text-xs">{@name}</Text.subtitle>
        </Layout.flex>
      </Layout.flex>
    </button>
    """
  end

  @doc false
  defp on_live_navigate(active_tab, href) do
    JS.push("on_live_navigate", value: %{active_tab: to_string(active_tab)})
    |> JS.patch(href)
  end
end
