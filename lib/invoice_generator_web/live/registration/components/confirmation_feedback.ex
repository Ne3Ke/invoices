defmodule InvoiceGeneratorWeb.ConfirmationFeedback.Component do
  use InvoiceGeneratorWeb, :live_component
  alias Tremorx.Components.Button
  alias Tremorx.Components.Layout

  @impl true

  def render(assigns) do
    ~H"""
    <div>
      <Layout.flex flex_direction="col" justify_content="center" class="my-10">
        <Layout.flex
          flex_direction="col"
          align_items="start"
          class="grow mb-4 bg-[#ebe6ff] py-8 px-6 my-10 max-w-4xl"
        >
          <Text.title class="text-xl my-4">
            <Text.bold>Confirm your Email Address</Text.bold>
          </Text.title>

          <Text.text color="black" class="mb-6">
            We've sent a confirmation email to <span class="bold">{@email}</span>.
            Please follow the link in the message to confirm your email address.If you did not receive the email,
            please check your spam folder or:
          </Text.text>

          <Button.button size="xl" phx-click={JS.patch(~p"/users/confirm")}>
            Resend Confirmation Instructions
          </Button.button>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
end
