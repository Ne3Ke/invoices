defmodule InvoiceGeneratorWeb.InvoiceLive.View.InvoiceComponent do
  use InvoiceGeneratorWeb, :live_component

  # alias InvoiceGenerator.{Records, Helpers}
  # alias InvoiceGenerator.Records.Invoice

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-[90%] max-w-3xl mx-auto bg-[#FFFFFF] rounded-lg pt-6 pb-8">
      <.link navigate={~p"/invoices/#{@invoice_id}"}>
        <div class="flex flex-col gap-4 md:hidden">
          <div class="flex justify-between items-center w-[90%] mx-auto">
            <section class="league-spartan-bold text-[#858BB2]">
              #<span class="text-[#0C0E16]">{first_six_letters(@invoice_id)}</span>
            </section>
            <section class="league-spartan-medium text-[#858BB2] text-sm">{@client_name}</section>
          </div>
          <div class="flex justify-between items-center w-[90%] mx-auto">
            <section class="flex flex-col gap-4">
              <div class="league-spartan-medium text-sm text-[#858BB2]">
                Due {date_formatter(@invoice_due)}
              </div>
              <div class="league-spartan-bold text-[#0C0E16]">£ {format_total(@invoice_total)}</div>
            </section>
            <section class={[
              "py-3 min-w-[8rem] flex justify-center items-center gap-3 rounded-md",
              get_classes_from_state(@invoice_state)
            ]}>
              <div><img src={return_status_button(@invoice_state)} alt="Status Button" /></div>
              <div class="league-spartan-bold">
                {@invoice_state}
              </div>
            </section>
          </div>
        </div>
      </.link>

      <.link navigate={~p"/invoices/#{@invoice_id}"}>
        <div class="hidden md:block">
          <div class="flex justify-between items-center gap-4 w-[90%] mx-auto">
            <div class="flex items-center gap-6">
              <section class="league-spartan-bold text-[#858BB2]">
                #<span class="text-[#0C0E16]">{first_six_letters(@invoice_id)}</span>
              </section>
              <section class="league-spartan-medium text-sm text-[#858BB2]">
                Due {date_formatter(@invoice_due)}
              </section>
            </div>
            <div class="flex items-center gap-6">
              <section class="league-spartan-medium text-[#858BB2] text-sm">{@client_name}</section>
              <section class="league-spartan-bold text-[#0C0E16]">
                £ {format_total(@invoice_total)}
              </section>
            </div>
            <div class="flex items-center gap-6">
              <section class={[
                "py-3 min-w-[8rem] flex justify-center items-center gap-3 rounded-md",
                get_classes_from_state(@invoice_state)
              ]}>
                <div><img src={return_status_button(@invoice_state)} alt="Status Button" /></div>
                <div class="league-spartan-bold">
                  {@invoice_state}
                </div>
              </section>
              <section>
                <img src={~p"/images/invoices/downarrow.svg"} alt="Down Arrow Image" />
              </section>
            </div>
          </div>
        </div>
      </.link>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    %{invoice_items: items} = assigns

    total = get_total_invoice_cost(items)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(invoice_total: total)}
  end

  def get_total_invoice_cost(items) do
    total = Enum.reduce(items, 0, fn x, acc -> x.total + acc end)
    total
  end

  def first_six_letters(word) when is_binary(word) do
    String.slice(word, 0, 6)
    |> String.upcase()
  end

  def date_formatter(date) do
    year = date.year
    day = date.day
    month = date.month

    month_index = month - 1

    list_of_months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ]

    "#{day} #{Enum.at(list_of_months, month_index)} #{year}"
  end

  def format_total(total) do
    formatted = :io_lib.format("~.2f", [total * 1.0]) |> to_string()
    formatted
  end

  defp return_status_button(state) do
    case state do
      :Pending ->
        ~p"/images/invoices/pending_circle.svg"

      :Paid ->
        ~p"/images/invoices/paid_circle.svg"

      :Draft ->
        ~p"/images/invoices/draft_circle.svg"
    end
  end

  defp get_classes_from_state(state) do
    case state do
      :Pending ->
        "text-[#FF8F00] bg-[#FF8F00] bg-opacity-[0.06]"

      :Paid ->
        "text-[#33D69F] bg-[#33D69F] bg-opacity-[0.06]"

      :Draft ->
        "text-[#373B53] bg-[#373B53] bg-opacity-[0.06]"
    end
  end
end
