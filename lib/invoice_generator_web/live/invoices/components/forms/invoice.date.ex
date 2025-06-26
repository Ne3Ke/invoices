defmodule InvoiceGeneratorWeb.InvoiceLive.DateComponent do
  use InvoiceGeneratorWeb, :live_component

  alias InvoiceGenerator.{Records, Helpers}
  alias InvoiceGenerator.Records.Invoice

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Invoice Date
              </Text.text>
            </label>

            <.input field={@form[:invoice_date]} readonly type="date" placeholder="Invoice Date..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Payment Terms
              </Text.text>
            </label>
            <Select.search_select
              id="invoice_due_id"
              name={@form[:invoice_due_days].name}
              placeholder="Payment terms"
              value={@form[:invoice_due_days].value}
              phx-update="ignore"
            >
              <:item :for={%{name: name} <- @payment_terms}>
                {name}
              </:item>
            </Select.search_select>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Project Description
              </Text.text>
            </label>

            <.input
              field={@form[:project_description]}
              type="text"
              placeholder="Project Description..."
            />
          </Layout.col>

          <Button.button
            type="submit"
            size="xl"
            class="mt-2 w-min hidden"
            phx-disable-with="Saving..."
          >
            Save Date Details
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
      send_date_details(invoice)
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(payment_terms: Helpers.payment_terms())
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"date_details" => date_params}, socket) do
    date_params = get_the_invoice_due_date(date_params)

    invoice = socket.assigns.invoice

    changeset = Records.change_invoice(invoice, date_params)

    _result =
      case Keyword.get(changeset.errors, :project_description) do
        nil ->
          # * description is valid

          invoice_date = changeset.data.invoice_date
          date_details = changeset.changes

          date_details = Map.put(date_details, :invoice_date, invoice_date)

          send(self(), {:valid_date_details, date_details})

          :ok

        _ ->
          # * description is invalid

          :error
      end

    form = to_form(changeset, action: :validate, as: "date_details")

    {:noreply,
     socket
     |> assign(form: form)}
  end

  @impl true
  def handle_event("save", %{"date_details" => date_params}, socket) do
    date_params = get_the_invoice_due_date(date_params)

    invoice = socket.assigns.invoice

    changeset = Records.change_invoice(invoice, date_params)

    form = to_form(changeset, action: :validate, as: "date_details")

    {:noreply,
     socket
     |> assign(form: form)}
  end

  defp assign_form(socket) do
    invoice =
      case Map.get(socket.assigns, :invoice) do
        nil ->
          invoice = %Invoice{
            invoice_date: Date.utc_today(),
            invoice_due_days: "Net 14 Days"
          }

          invoice

        invoice ->
          due_date = invoice.invoice_due
          invoice_date = invoice.invoice_date
          description = invoice.project_description

          due_days = Date.diff(due_date, invoice_date)

          due_days =
            case due_days == 1 do
              true -> "Net #{due_days} Day"
              false -> "Net #{due_days} Days"
            end

          invoice = %Invoice{
            invoice_date: invoice_date,
            invoice_due_days: due_days,
            project_description: description
          }

          invoice
      end

    socket = create_and_assign_form(socket, invoice)
    socket
  end

  defp create_and_assign_form(socket, invoice, params \\ %{}) do
    changeset = Records.change_invoice(invoice, params)

    form = to_form(changeset, as: "date_details")

    socket =
      socket
      |> assign(invoice: invoice)
      |> assign(form: form)

    socket
  end

  defp get_the_invoice_due_date(params) do
    due_days = params["invoice_due_days"]
    invoice_date_string = params["invoice_date"]
    map = Helpers.string_mappings_of_days()
    days = map[due_days]

    {:ok, invoice_date} = Date.from_iso8601(invoice_date_string)

    due_date = Date.add(invoice_date, days)

    params = Map.merge(params, %{"invoice_due" => due_date})

    params
  end

  defp send_date_details(invoice) do
    date_details = %{
      invoice_due: invoice.invoice_due,
      invoice_date: invoice.invoice_date,
      project_description: invoice.project_description
    }

    send(self(), {:valid_date_details, date_details})
  end
end
