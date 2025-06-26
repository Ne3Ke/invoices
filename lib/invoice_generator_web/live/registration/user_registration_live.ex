defmodule InvoiceGeneratorWeb.UserRegistrationLive do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.{Accounts, Helpers}
  alias InvoiceGenerator.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="border border-blue-400">
      <%= if @confirm do %>
        <div class="border border-red-400">
          <.live_component
            module={InvoiceGeneratorWeb.ConfirmationFeedback.Component}
            id="feedback_confirmation"
            email={@email}
          />
        </div>
      <% else %>
        <Layout.flex flex_direction="col" justify_content="center" class="my-10">
          <Layout.flex
            flex_direction="col"
            align_items="start"
            class="grow mb-4 border border-red-400 py-8 px-6 my-10 max-w-4xl"
          >
            <.header class="text-center border w-full border-red-400">
              Register for an account
              <:subtitle>
                Already registered?
                <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
                  Log in
                </.link>
                to your account now.
              </:subtitle>
            </.header>

            <div class="w-full">
              <.form
                for={@form}
                id="registration_form"
                phx-submit="save"
                phx-change="validate"
                phx-trigger-action={@trigger_submit}
                action={~p"/users/log_in?_action=registered"}
                method="post"
              >
                <.error :if={@check_errors}>
                  Oops, something went wrong! Please check the errors below.
                </.error>

                <.input field={@form[:name]} type="text" label="Name" placeholder="Enter Your Name" />
                <.input
                  field={@form[:username]}
                  type="text"
                  label="Username"
                  placeholder="Enter Your Username"
                  required
                />
                <.input
                  field={@form[:email]}
                  type="email"
                  label="Email"
                  placeholder="Enter Your Email"
                />

                <Layout.col class="space-y-1.5">
                  <label for="password">
                    <Text.text class="text-tremor-content font-extrabold text-black">
                      Password
                    </Text.text>
                  </label>

                  <Input.text_input
                    id="password"
                    name="user[password]"
                    placeholder="Enter Your Password"
                    type="password"
                    field={@form[:password]}
                    value={@form[:password].value}
                  />
                </Layout.col>

                <.live_component
                  module={InvoiceGeneratorWeb.Password.Validation.Component}
                  id="password_validation_component"
                  form_errors={@form_errors}
                />

                <Button.button
                  type="submit"
                  size="xl"
                  class="mt-4"
                  phx-disable-with="Creating account..."
                >
                  Sign Up
                </Button.button>
              </.form>
            </div>

            <Layout.flex
              class="space-x-2 underline cursor-pointer decoration-2"
              justify_content="start"
            >
              <Text.subtitle color="gray">
                Already have an account?
              </Text.subtitle>

              <a href="/users/log_in" class="cursor-pointer decoration-2 text-blue-400">
                <Text.subtitle color="blue">
                  Login
                </Text.subtitle>
              </a>
            </Layout.flex>
          </Layout.flex>
        </Layout.flex>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(confirm: false)
      |> assign(email: "")
      |> assign_form(changeset)
      |> assign(form_errors: Helpers.initial_errors())

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        _changeset = Accounts.change_user_registration(user)

        {:noreply,
         socket
         |> assign(trigger_submit: true)
         #  |> assign_form(changeset)
         |> assign(confirm: true)
         |> assign(email: user.email)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => %{"password" => password} = user_params}, socket) do
    changeset = Accounts.change_user_registration_sign_up(%User{}, user_params)
    errors = Helpers.get_map_of_errors(changeset.errors)

    socket =
      if password == "" do
        socket
        |> assign(form_errors: Helpers.initial_errors())
      else
        socket
        |> assign(form_errors: errors)
      end

    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
