defmodule InvoiceGeneratorWeb.UserProfileLiveTest do
  use InvoiceGeneratorWeb.ConnCase

  import Phoenix.LiveViewTest
  import InvoiceGenerator.ProfileFixtures

  @create_attrs %{
    country: "some country",
    city: "some city",
    phone: "some phone",
    postal_code: "some postal_code",
    street: "some street"
  }
  @update_attrs %{
    country: "some updated country",
    city: "some updated city",
    phone: "some updated phone",
    postal_code: "some updated postal_code",
    street: "some updated street"
  }
  @invalid_attrs %{country: nil, city: nil, phone: nil, postal_code: nil, street: nil}

  defp create_user_profile(_) do
    user_profile = user_profile_fixture()
    %{user_profile: user_profile}
  end

  describe "Index" do
    setup [:create_user_profile]

    test "lists all profiles", %{conn: conn, user_profile: user_profile} do
      {:ok, _index_live, html} = live(conn, ~p"/profiles")

      assert html =~ "Listing Profiles"
      assert html =~ user_profile.country
    end

    test "saves new user_profile", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/profiles")

      assert index_live |> element("a", "New User profile") |> render_click() =~
               "New User profile"

      assert_patch(index_live, ~p"/profiles/new")

      assert index_live
             |> form("#user_profile-form", user_profile: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#user_profile-form", user_profile: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/profiles")

      html = render(index_live)
      assert html =~ "User profile created successfully"
      assert html =~ "some country"
    end

    test "updates user_profile in listing", %{conn: conn, user_profile: user_profile} do
      {:ok, index_live, _html} = live(conn, ~p"/profiles")

      assert index_live |> element("#profiles-#{user_profile.id} a", "Edit") |> render_click() =~
               "Edit User profile"

      assert_patch(index_live, ~p"/profiles/#{user_profile}/edit")

      assert index_live
             |> form("#user_profile-form", user_profile: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#user_profile-form", user_profile: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/profiles")

      html = render(index_live)
      assert html =~ "User profile updated successfully"
      assert html =~ "some updated country"
    end

    test "deletes user_profile in listing", %{conn: conn, user_profile: user_profile} do
      {:ok, index_live, _html} = live(conn, ~p"/profiles")

      assert index_live |> element("#profiles-#{user_profile.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#profiles-#{user_profile.id}")
    end
  end

  describe "Show" do
    setup [:create_user_profile]

    test "displays user_profile", %{conn: conn, user_profile: user_profile} do
      {:ok, _show_live, html} = live(conn, ~p"/profiles/#{user_profile}")

      assert html =~ "Show User profile"
      assert html =~ user_profile.country
    end

    test "updates user_profile within modal", %{conn: conn, user_profile: user_profile} do
      {:ok, show_live, _html} = live(conn, ~p"/profiles/#{user_profile}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit User profile"

      assert_patch(show_live, ~p"/profiles/#{user_profile}/show/edit")

      assert show_live
             |> form("#user_profile-form", user_profile: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#user_profile-form", user_profile: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/profiles/#{user_profile}")

      html = render(show_live)
      assert html =~ "User profile updated successfully"
      assert html =~ "some updated country"
    end
  end
end
