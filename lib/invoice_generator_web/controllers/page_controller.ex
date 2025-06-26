defmodule InvoiceGeneratorWeb.PageController do
  use InvoiceGeneratorWeb, :controller

  def home(conn, _params) do
    if conn.assigns.current_user == nil do
      redirect(conn, to: "/welcome")
    else
      redirect(conn, to: "/home")
    end
  end
end
