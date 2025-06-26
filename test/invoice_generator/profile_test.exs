defmodule InvoiceGenerator.ProfileTest do
  use InvoiceGenerator.DataCase

  alias InvoiceGenerator.Profile

  describe "profiles" do
    alias InvoiceGenerator.Profile.UserProfile

    import InvoiceGenerator.ProfileFixtures

    @invalid_attrs %{country: nil, city: nil, phone: nil, postal_code: nil, street: nil}

    test "list_profiles/0 returns all profiles" do
      user_profile = user_profile_fixture()
      assert Profile.list_profiles() == [user_profile]
    end

    test "get_user_profile!/1 returns the user_profile with given id" do
      user_profile = user_profile_fixture()
      assert Profile.get_user_profile!(user_profile.id) == user_profile
    end

    test "create_user_profile/1 with valid data creates a user_profile" do
      valid_attrs = %{
        country: "some country",
        city: "some city",
        phone: "some phone",
        postal_code: "some postal_code",
        street: "some street"
      }

      assert {:ok, %UserProfile{} = user_profile} = Profile.create_user_profile(valid_attrs)
      assert user_profile.country == "some country"
      assert user_profile.city == "some city"
      assert user_profile.phone == "some phone"
      assert user_profile.postal_code == "some postal_code"
      assert user_profile.street == "some street"
    end

    test "create_user_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profile.create_user_profile(@invalid_attrs)
    end

    test "update_user_profile/2 with valid data updates the user_profile" do
      user_profile = user_profile_fixture()

      update_attrs = %{
        country: "some updated country",
        city: "some updated city",
        phone: "some updated phone",
        postal_code: "some updated postal_code",
        street: "some updated street"
      }

      assert {:ok, %UserProfile{} = user_profile} =
               Profile.update_user_profile(user_profile, update_attrs)

      assert user_profile.country == "some updated country"
      assert user_profile.city == "some updated city"
      assert user_profile.phone == "some updated phone"
      assert user_profile.postal_code == "some updated postal_code"
      assert user_profile.street == "some updated street"
    end

    test "update_user_profile/2 with invalid data returns error changeset" do
      user_profile = user_profile_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Profile.update_user_profile(user_profile, @invalid_attrs)

      assert user_profile == Profile.get_user_profile!(user_profile.id)
    end

    test "delete_user_profile/1 deletes the user_profile" do
      user_profile = user_profile_fixture()
      assert {:ok, %UserProfile{}} = Profile.delete_user_profile(user_profile)
      assert_raise Ecto.NoResultsError, fn -> Profile.get_user_profile!(user_profile.id) end
    end

    test "change_user_profile/1 returns a user_profile changeset" do
      user_profile = user_profile_fixture()
      assert %Ecto.Changeset{} = Profile.change_user_profile(user_profile)
    end
  end
end
