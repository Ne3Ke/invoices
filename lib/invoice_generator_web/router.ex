defmodule InvoiceGeneratorWeb.Router do
  use InvoiceGeneratorWeb, :router

  import InvoiceGeneratorWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {InvoiceGeneratorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", InvoiceGeneratorWeb do
    pipe_through :browser

    get "/", PageController, :home
    # live "/welcome", WelcomeLive.Index\
    live "/welcome", WelcomeLive.Index
  end

  # Other scopes may use custom stacks.
  # scope "/api", InvoiceGeneratorWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:invoice_generator, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: InvoiceGeneratorWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", InvoiceGeneratorWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      # * Tip: if you need to define multiple on_mount callbacks,
      # * avoid defining multiple modules. Instead, pass a tuple and use
      # * pattern matching to handle different cases
      on_mount: [{InvoiceGeneratorWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/register/:id", UserRegistrationLive.Show
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", InvoiceGeneratorWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{InvoiceGeneratorWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/profiles", UserProfileLive.Index, :index

      live "/home", HomeLive.Index, :index

      live "/personaldetails", SettingsLive.Index, :index
      live "/password", SettingsLive.Password, :index
      live "/emailnotifications", SettingsLive.EmailNotifications, :index

      live "/invoices", InvoiceLive.Index, :index
      live "/invoices/new", InvoiceLive.Index, :new
      live "/invoices/:id/edit", InvoiceLive.Index, :edit

      live "/invoices/:id", InvoiceLive.Show, :show
    end
  end

  scope "/", InvoiceGeneratorWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{InvoiceGeneratorWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
