defmodule InvoiceGenerator.Accounts.UserNotifier do
  # import Swoosh.Email

  alias InvoiceGenerator.Mailer

  use Phoenix.Swoosh,
    template_root: "lib/invoice_generator_web/templates",
    template_path: "emails"

  # Delivers the email using the application mailer.
  defp deliver(user, url, subject, template) do
    email =
      new()
      |> to(user.email)
      |> from({"InvoiceGenerator", "shattymtana@gmail.com"})
      |> subject(subject)
      |> render_body(template, %{the_email: user.email, name: user.name, url: url})
      |> attachment(
        Swoosh.Attachment.new(
          Path.absname("priv/static/images/logo.png"),
          type: :inline
        )
      )

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user, url, "Confirmation instructions", "confirm.html")
  end

  @doc """
  Deliver instructions to reset a user password.
  """

  def deliver_reset_password_instructions(user, url) do
    deliver(user, url, "Reset password instructions", "password.html")
  end

  @doc """
  Deliver instructions to update a user email.
  """

  # * Not used for now
  def deliver_update_email_instructions(user, url) do
    deliver(user, url, "Update email instructions", "update_email.html")
  end
end
