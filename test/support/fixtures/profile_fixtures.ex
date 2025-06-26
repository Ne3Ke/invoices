defmodule InvoiceGenerator.ProfileFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceGenerator.Profile` context.
  """

  @doc """
  Generate a user_profile.
  """
  def user_profile_fixture(attrs \\ %{}) do
    {:ok, user_profile} =
      attrs
      |> Enum.into(%{
        city: "some city",
        country: "some country",
        phone: "some phone",
        postal_code: "some postal_code",
        street: "some street"
      })
      |> InvoiceGenerator.Profile.create_user_profile()

    user_profile
  end
end
