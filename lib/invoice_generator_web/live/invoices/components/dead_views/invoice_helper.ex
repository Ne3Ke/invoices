defmodule InvoiceGeneratorWeb.InvoiceLive.DeadView.InvoiceHelper do
  use InvoiceGeneratorWeb, :html
  use Phoenix.Component

  attr :invoice_state, :atom, required: true

  @doc """
  Renders a user profile menu
  """
  def invoice_state_button(assigns) do
    ~H"""
    <section class={[
      "py-3 min-w-[8rem] flex justify-center items-center gap-3 rounded-md",
      get_classes_from_state(@invoice_state)
    ]}>
      <div><img src={return_status_button(@invoice_state)} alt="Status Button" /></div>
      <div class="league-spartan-bold text-base">
        {@invoice_state}
      </div>
    </section>
    """
  end

  attr :invoice_state, :atom, required: true

  @doc """
  Renders a user profile menu
  """
  def individual_invoice_state_button(assigns) do
    ~H"""
    <section class={[
      "py-2 px-6 flex justify-center items-center gap-3 rounded-md",
      get_classes_from_state(@invoice_state)
    ]}>
      <div><img src={return_status_button(@invoice_state)} alt="Status Button" /></div>
      <div class="league-spartan-bold text-base">
        {@invoice_state}
      </div>
    </section>
    """
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
end
