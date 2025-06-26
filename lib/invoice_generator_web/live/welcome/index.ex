defmodule InvoiceGeneratorWeb.WelcomeLive.Index do
  @moduledoc """
  The welcome to our Application.
  """

  use InvoiceGeneratorWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center">
      <section class="w-full flex flex-col items-center justify-start gap-6  h-[90vh] py-8">
        <div class="flex flex-row justify-center items-center gap-6  w-full">
          <section>
            <img src={~p"/images/mobilelogo.svg"} width="80" />
          </section>
          <section class="font-semibold text-[#7c5dfa] text-4xl">Invoice</section>
        </div>
        <div class="w-full flex flex-col items-center mb-20 text-2xl font-semibold">
          <div class="text-tremor-content-emphasis text-2xl text-bold">Sign in to Invoice</div>
        </div>
        <.link
          class="flex flex-row justify-center items-center gap-6 w-[75%] mb-10 py-2 border rounded-full"
          patch={~p"/"}
        >
          <section class="w-6">
            <img class="object-cover" src={~p"/images/googlesmall.svg"} />
          </section>
          <Text.text class="text-3xl">Sign in with Google</Text.text>
        </.link>
        <.link
          class="flex flex-row justify-center items-center gap-6 w-[75%] mb-10 py-2 border rounded-full"
          patch={~p"/users/register"}
        >
          <section class="w-6">
            <img class="object-cover" src={~p"/images/email.svg"} />
          </section>
          <Text.text class="text-3xl">Continue with email</Text.text>
        </.link>

        <div class="w-[68%] text-center text-gray-500 text-sm">
          <p>By creating an account, you agree to</p>
          <p class="mt-1">Invoice company's</p>
          <p class="mt-1">
            <span class="font-bold text-gray-500">Terms of use</span>
            and <span class="font-bold text-gray-500">Privacy Policy.</span>
          </p>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
