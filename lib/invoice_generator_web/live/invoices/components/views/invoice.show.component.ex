defmodule InvoiceGeneratorWeb.InvoiceLive.Show.InvoiceLarge do
  @moduledoc """
  the invoice at large screen sizes
  """

  use InvoiceGeneratorWeb, :live_component

  alias InvoiceGeneratorWeb.InvoiceLive.DeadView.InvoiceHelper
  alias InvoiceGeneratorWeb.InvoiceLive.View.InvoiceComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto hidden sm:block text-sm text-[#7E88C3]">
      <div class="w-full mt-8">
        <.link navigate={~p"/invoices"}>
          <div class="flex items-center gap-6">
            <section>
              <img src={~p"/images/invoices/back_arrow2.svg"} alt="Back Arrow 2" />
            </section>
            <section class="league-spartan-bold text-[#0C0E16] text-base">Go back</section>
          </div>
        </.link>
      </div>

      <div class="py-6 rounded-lg my-10 bg-[#FFFFFF]">
        <div class="w-[92%] mx-auto flex justify-between items-center">
          <section class="flex gap-4 items-center">
            <div class="league-spartan-medium">Status</div>
            <div>
              <InvoiceHelper.individual_invoice_state_button invoice_state={@invoice_state} />
            </div>
          </section>
          <section class="flex gap-4">
            <section>
              <button
                class="bg-[#F9FAFE] rounded-full text-[#7E88C3] league-spartan-bold rounded-full px-6 py-3"
                phx-click={JS.patch(return_edit_path(@invoice_id))}
              >
                Edit
              </button>
            </section>
            <section>
              <button
                class="bg-[#EC5757] rounded-full text-[#FFFFFF] league-spartan-bold rounded-full px-6 py-3"
                phx-click={JS.patch(~p"/invoices/new")}
              >
                Delete
              </button>
            </section>
            <section>
              <button
                class="bg-[#7C5DFA] rounded-full text-[#FFFFFF] league-spartan-bold rounded-full px-6 py-3"
                phx-click={JS.patch(~p"/invoices/new")}
              >
                Mark as Paid
              </button>
            </section>
          </section>
        </div>
      </div>
      <div class="py-6 rounded-lg bg-[#FFFFFF]">
        <div class="w-[86%] mx-auto">
          <section class="flex justify-between">
            <div class="flex flex-col gap-1">
              <section class="league-spartan-bold text-[#858BB2]">
                #<span class="text-[#0C0E16]">{InvoiceComponent.first_six_letters(@invoice_id)}</span>
              </section>
              <section class="league-spartan-medium">
                {@description}
              </section>
            </div>
            <div class="flex flex-col gap-1 league-spartan-medium">
              <section>{@sender_address}</section>
              <section>{@sender_city}</section>
              <section>
                {@sender_postcode}
              </section>
              <section>
                {@sender_country}
              </section>
            </div>
          </section>

          <section class="flex flex-col gap-2">
            <section class="flex justify-start gap-28">
              <div class="flex flex-col">
                <section class="league-spartan-medium">Invoice Date</section>
                <section class="text-[#0C0E16] league-spartan-bold text-base">
                  {InvoiceComponent.date_formatter(@invoice_date)}
                </section>
              </div>

              <div class="flex flex-col">
                <section class="league-spartan-medium">Bill To</section>
                <section class="text-[#0C0E16] league-spartan-bold text-base">
                  {@receiver_name}
                </section>
              </div>

              <div class="flex flex-col">
                <section class="league-spartan-medium">Sent to</section>
                <section class="text-[#0C0E16] league-spartan-bold text-base">
                  {@receiver_email}
                </section>
              </div>
            </section>

            <section class="flex justify-start gap-28 league-spartan-medium">
              <div class="flex flex-col gap-3">
                <section>Payment Due</section>
                <section class="text-[#0C0E16] league-spartan-bold text-base">
                  {InvoiceComponent.date_formatter(@due_date)}
                </section>
              </div>
              <div class="flex flex-col gap-1">
                <section>{@receiver_address}</section>
                <section>
                  {@receiver_city}
                </section>
                <section>
                  {@receiver_postcode}
                </section>
                <section>
                  {@receiver_country}
                </section>
              </div>
            </section>
          </section>

          <div class="bg-[#F9FAFE] rounded-lg pt-10 overflow-hidden">
            <div class=" w-[94%] mx-auto flex gap-16 mb-10">
              <section class="w-[35%] flex flex-col gap-8">
                <div class="league-spartan-medium">Item Name</div>
                <%= for item <- @items do %>
                  <div class="league-spartan-bold text-base text-[#0C0E16]">{item.name}</div>
                <% end %>
              </section>

              <section class="flex flex-col items-center gap-8">
                <div class="league-spartan-medium">QTY</div>
                <%= for item <- @items do %>
                  <div class="league-spartan-bold text-base">{item.quantity}</div>
                <% end %>
              </section>

              <section class="flex flex-col items-end gap-8">
                <div class="league-spartan-medium">Price</div>

                <%= for item <- @items do %>
                  <div class="league-spartan-bold text-base">
                    £ {InvoiceComponent.format_total(item.price)}
                  </div>
                <% end %>
              </section>

              <section class="flex flex-col items-end gap-8">
                <div class="league-spartan-medium">Total</div>
                <%= for item <- @items do %>
                  <div class="league-spartan-bold text-base text-[#0C0E16]">
                    £ {InvoiceComponent.format_total(item.total)}
                  </div>
                <% end %>
              </section>
            </div>

            <div class="bg-[#373B53] py-10">
              <div class="w-[94%] mx-auto flex justify-between items-center text-[#FFFFFF]">
                <section class="league-spartan-medium">Amount Due</section>
                <section class="league-spartan-bold text-2xl md:pr-14">
                  £ {InvoiceComponent.format_total(@total_item_cost)}
                </section>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  defp return_edit_path(id) do
    ~p"/invoices/#{id}/edit"
  end
end
