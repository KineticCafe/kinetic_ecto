defmodule KineticEcto.ChangesetValidations.ValidateSomeRequiredTest do
  use ExUnit.Case, async: true

  import KineticEcto.ChangesetValidations

  alias Ecto.Changeset
  alias KineticEcto.TestImage, as: Image

  describe "validate_some_required/3" do
    setup do
      {:ok, changeset: Image.changeset(%{})}
    end

    @fields [:color, :hsla, :rgba, :url]

    test "[PASS] if minimum <= 0 and maximum = nil", %{changeset: changeset} do
      assert %Changeset{valid?: true} =
               validate_some_required(changeset, @fields, minimum: 0)

      assert %Changeset{valid?: true} =
               validate_some_required(changeset, @fields, minimum: -1)
    end

    test "[FAIL] acts as validate_required/3 if minimum = count", %{changeset: changeset} do
      assert %Changeset{valid?: false, errors: errors} =
               validate_some_required(changeset, @fields, minimum: 4)

      assert {"can't be blank", [validation: :required]} = Keyword.get(errors, :color)
      assert {"can't be blank", [validation: :required]} = Keyword.get(errors, :hsla)
      assert {"can't be blank", [validation: :required]} = Keyword.get(errors, :rgba)
      assert {"can't be blank", [validation: :required]} = Keyword.get(errors, :url)
    end

    test "[FAIL] acts as validate_required/3 if minimum > count", %{changeset: changeset} do
      assert %Changeset{valid?: false, errors: errors} =
               validate_some_required(changeset, @fields, minimum: 6)

      assert {"can't be blank", [validation: :required]} = Keyword.get(errors, :color)
      assert {"can't be blank", [validation: :required]} = Keyword.get(errors, :hsla)
      assert {"can't be blank", [validation: :required]} = Keyword.get(errors, :rgba)
      assert {"can't be blank", [validation: :required]} = Keyword.get(errors, :url)
    end

    test "[FAIL] if no field is set with minimum = 1 (default)", %{changeset: changeset} do
      assert %Changeset{valid?: false, errors: errors} =
               validate_some_required(changeset, @fields)

      assert {"at least one field must be present", [minimum: 1, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :color)

      assert {"at least one field must be present", [minimum: 1, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :hsla)

      assert {"at least one field must be present", [minimum: 1, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :rgba)

      assert {"at least one field must be present", [minimum: 1, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :url)
    end

    test "[PASS] if at least one field is set with minimum = 1 (default)", %{changeset: changeset} do
      assert %Changeset{valid?: true} =
               changeset
               |> put_color()
               |> validate_some_required(@fields)

      assert %Changeset{valid?: true} =
               changeset
               |> put_color()
               |> put_url()
               |> validate_some_required(@fields)
    end

    test "[FAIL] if more than one field is set with maximum = 1", %{changeset: changeset} do
      assert %Changeset{valid?: false, errors: errors} =
               changeset
               |> put_color()
               |> put_url()
               |> validate_some_required(@fields, maximum: 1)

      assert {"at most one field may be present", [minimum: 1, maximum: 1, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :color)

      assert {"at most one field may be present", [minimum: 1, maximum: 1, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :hsla)

      assert {"at most one field may be present", [minimum: 1, maximum: 1, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :rgba)

      assert {"at most one field may be present", [minimum: 1, maximum: 1, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :url)
    end

    test "[FAIL] maximum < 1 is normalized to maximum = 1", %{changeset: changeset} do
      assert %Changeset{valid?: false, errors: errors} =
               changeset
               |> put_color()
               |> put_url()
               |> validate_some_required(@fields, maximum: 0)

      assert {"at most one field may be present", [minimum: 1, maximum: 1, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :color)
    end

    test "[PASS] if at exactly one field is set with maximum = 1", %{changeset: changeset} do
      assert %Changeset{valid?: true} =
               changeset
               |> Changeset.put_change(:color, "#fff")
               |> validate_some_required(@fields)

      assert %Changeset{valid?: true} =
               changeset
               |> Changeset.put_change(:url, "https://example.com")
               |> validate_some_required(@fields)
    end

    test "[FAIL] maximum > count is normalized to maximum = count", %{changeset: changeset} do
      assert %Changeset{valid?: false, errors: errors} =
               validate_some_required(changeset, [:color, :url], maximum: 3)

      assert {"at least one field must be present",
              [minimum: 1, maximum: 2, fields: [:color, :url], validation: :some_required]} =
               Keyword.get(errors, :color)
    end

    test "[FAIL] maximum < minimum is normalized to maximum = minimum", %{changeset: changeset} do
      assert %Changeset{valid?: false, errors: errors} =
               validate_some_required(changeset, @fields, minimum: 3, maximum: 2)

      assert {"at least 3 fields must be present",
              [minimum: 3, maximum: 3, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :color)
    end

    test "[FAIL] if one field is set with minimum = 2, maximum = 3", %{changeset: changeset} do
      assert %Changeset{valid?: false, errors: errors} =
               changeset
               |> Changeset.put_change(:url, "https://example.com")
               |> validate_some_required(@fields, minimum: 2, maximum: 3)

      assert {"at least 2 fields must be present",
              [minimum: 2, maximum: 3, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :color)

      assert {"at least 2 fields must be present",
              [minimum: 2, maximum: 3, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :hsla)

      assert {"at least 2 fields must be present",
              [minimum: 2, maximum: 3, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :rgba)

      assert {"at least 2 fields must be present",
              [minimum: 2, maximum: 3, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :url)
    end

    test "[PASS] if two or three fields are set with minimum = 2, maximum = 3", %{changeset: changeset} do
      assert %Changeset{valid?: true} =
               changeset
               |> Changeset.put_change(:color, "#fff")
               |> Changeset.put_change(:url, "https://example.com")
               |> validate_some_required(@fields, minimum: 2, maximum: 3)

      assert %Changeset{valid?: true} =
               changeset
               |> Changeset.put_change(:color, "#fff")
               |> Changeset.put_change(:url, "https://example.com")
               |> Changeset.put_embed(:rgba, %{red: 0.9, green: 0.8, blue: 0.7, alpha: 0.3})
               |> validate_some_required(@fields, minimum: 2, maximum: 3)
    end

    test "[FAIL] if four fields are set with minimum = 2, maximum = 3", %{changeset: changeset} do
      assert %Changeset{valid?: false, errors: errors} =
               changeset
               |> put_color()
               |> put_url()
               |> put_rgba()
               |> put_hsla()
               |> validate_some_required(@fields, minimum: 2, maximum: 3)

      assert {"at most 3 fields may be present", [minimum: 2, maximum: 3, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :color)

      assert {"at most 3 fields may be present", [minimum: 2, maximum: 3, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :hsla)

      assert {"at most 3 fields may be present", [minimum: 2, maximum: 3, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :rgba)

      assert {"at most 3 fields may be present", [minimum: 2, maximum: 3, fields: @fields, validation: :some_required]} =
               Keyword.get(errors, :url)
    end

    defp put_color(changeset), do: Changeset.put_change(changeset, :color, "#fff")
    defp put_url(changeset), do: Changeset.put_change(changeset, :url, "https://example.com")
    defp put_rgba(changeset), do: Changeset.put_embed(changeset, :rgba, %{red: 0.9, green: 0.8, blue: 0.7, alpha: 0.3})

    defp put_hsla(changeset),
      do: Changeset.put_embed(changeset, :hsla, %{hue: 0.9, saturation: 0.8, luminance: 0.7, alpha: 0.3})
  end

  # describe "validate_required_inclusion/2" do
  #   test "marks all fields if all are missing" do
  #     changeset = Image.changeset(%Image{}, %{})

  #     assert %Changeset{valid?: false, errors: errors} = changeset
  #     assert Keyword.has_key?(errors, :color)
  #     assert Keyword.has_key?(errors, :url)
  #   end

  #   test "detects the value as present if already in the schema" do
  #     changeset = Image.changeset(%Image{url: "here"}, %{})
  #     assert %Changeset{valid?: true} = changeset
  #   end

  #   test "detects the value as present if in the params" do
  #     changeset = Image.changeset(%Image{}, %{"url" => "here"})
  #     assert %Changeset{valid?: true} = changeset
  #   end

  #   test "detects an override to invalid" do
  #     changeset = Image.changeset(%Image{url: "here"}, %{"url" => nil})

  #     assert %Changeset{valid?: false, errors: errors} = changeset
  #     assert Keyword.has_key?(errors, :color)
  #     assert Keyword.has_key?(errors, :url)
  #   end

  #   test "detects when an immutable field is being changed" do
  #     changeset = Image.changeset(%Image{url: "here", immutable: "no"}, %{immutable: "yes"})
  #     assert %Changeset{valid?: false, errors: errors} = changeset
  #     assert Keyword.has_key?(errors, :immutable)
  #   end
  # end
end
