defmodule InvoiceGeneratorWeb.InvoiceLive.DetailsComponent do
  use InvoiceGeneratorWeb, :live_component

  alias InvoiceGenerator.{Records, Helpers}
  alias InvoiceGenerator.Records.Invoice

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold>{@title}</Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Use this form to manage invoice records in your database.
        </Text.subtitle>

        <Layout.divider class="my-4" />

        <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  Street Address
                </Text.text>

                <section><img src={~p"/images/star.svg"} width="8" /></section>
              </Layout.flex>
            </label>

            <.input field={@form[:from_address]} type="text" placeholder="Street Address..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  City
                </Text.text>

                <section><img src={~p"/images/star.svg"} width="8" /></section>
              </Layout.flex>
            </label>

            <.input field={@form[:from_city]} type="text" placeholder="City..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  Post Code
                </Text.text>

                <section><img src={~p"/images/star.svg"} width="8" /></section>
              </Layout.flex>
            </label>

            <.input field={@form[:from_post_code]} type="text" placeholder="Postal Code..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  Country
                </Text.text>

                <section><img src={~p"/images/star.svg"} width="8" /></section>
              </Layout.flex>
            </label>

            <.input field={@form[:from_country]} type="text" placeholder="Country..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  Client's Name
                </Text.text>

                <section><img src={~p"/images/star.svg"} width="8" /></section>
              </Layout.flex>
            </label>

            <.input field={@form[:to_client_name]} type="text" placeholder="Client's Name..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  Client's Email
                </Text.text>

                <section><img src={~p"/images/star.svg"} width="8" /></section>
              </Layout.flex>
            </label>

            <.input field={@form[:to_client_email]} type="text" placeholder=" Client's Email..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  Street Address
                </Text.text>

                <section><img src={~p"/images/star.svg"} width="8" /></section>
              </Layout.flex>
            </label>

            <.input field={@form[:to_address]} type="text" placeholder="Street Address..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  City
                </Text.text>

                <section><img src={~p"/images/star.svg"} width="8" /></section>
              </Layout.flex>
            </label>

            <.input field={@form[:to_city]} type="text" placeholder="City..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  Post Code
                </Text.text>

                <section><img src={~p"/images/star.svg"} width="8" /></section>
              </Layout.flex>
            </label>

            <.input field={@form[:to_post_code]} type="text" placeholder="Postal Code..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  Country
                </Text.text>

                <section><img src={~p"/images/star.svg"} width="8" /></section>
              </Layout.flex>
            </label>

            <.input field={@form[:to_country]} type="text" placeholder="Country..." />
          </Layout.col>

          <Button.button
            type="submit"
            size="xl"
            class="mt-2 w-min hidden"
            phx-disable-with="Saving..."
          >
            Save Business Details
          </Button.button>
        </.form>
      </Layout.col>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    invoice = assigns.invoice

    if invoice do
      send_combined_data(invoice)
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"invoice_details" => invoice_params}, socket) do
    invoice = socket.assigns.invoice

    changeset = Records.change_invoice_details(invoice, invoice_params)

    _validity_status =
      case changeset.valid? do
        true ->
          data = changeset.data

          sender_initial_data = extract_changeset_data(data)

          combined_business_data = Map.merge(sender_initial_data, changeset.changes)

          dbg(combined_business_data)

          send(self(), {:valid_business_details, combined_business_data})

          :ok

        false ->
          :error
      end

    form = to_form(changeset, action: :validate, as: "invoice_details")

    {:noreply,
     socket
     |> assign(form: form)}
  end

  @impl true
  def handle_event("save", %{"invoice_details" => invoice_params}, socket) do
    invoice = socket.assigns.invoice

    changeset = Records.change_invoice_details(invoice, invoice_params)

    form = to_form(changeset, action: :validate, as: "invoice_details")

    {:noreply,
     socket
     |> assign(form: form)}
  end

  defp assign_form(socket) do
    case Map.get(socket.assigns, :invoice) do
      nil ->
        user_id = socket.assigns.current_user

        case Helpers.get_user(user_id) do
          nil ->
            invoice = %Invoice{user_id: user_id}

            socket = create_and_assign_form(socket, invoice)
            socket

          user_profile ->
            invoice = %Invoice{
              user_id: user_id,
              from_address: user_profile.street,
              from_city: user_profile.city,
              from_country: user_profile.country,
              from_post_code: user_profile.postal_code
            }

            socket = create_and_assign_form(socket, invoice)
            socket
        end

      invoice ->
        socket = create_and_assign_form(socket, invoice)
        socket
    end
  end

  defp create_and_assign_form(socket, invoice, params \\ %{}) do
    changeset = Records.change_invoice_details(invoice, params)

    form = to_form(changeset, as: "invoice_details")

    socket =
      socket
      |> assign(invoice: invoice)
      |> assign(form: form)

    socket
  end

  defp extract_changeset_data(data) do
    %{
      user_id: data.user_id,
      from_address: data.from_address,
      from_city: data.from_city,
      from_post_code: data.from_post_code,
      from_country: data.from_country
    }
  end

  defp send_combined_data(invoice) do
    combined_business_data = %{
      to_address: invoice.to_address,
      user_id: invoice.user_id,
      to_client_name: invoice.to_client_name,
      from_address: invoice.from_address,
      from_city: invoice.from_city,
      from_country: invoice.from_country,
      from_post_code: invoice.from_post_code,
      to_city: invoice.to_city,
      to_client_email: invoice.to_client_email,
      to_country: invoice.to_country,
      to_post_code: invoice.to_post_code
    }

    send(self(), {:valid_business_details, combined_business_data})
  end
end
