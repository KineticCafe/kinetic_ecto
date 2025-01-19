defmodule KineticEcto.ChangesetValidations.ValidateImmutableTest do
  use ExUnit.Case, async: true

  import KineticEcto.ChangesetValidations, only: [validate_immutable: 2, validate_immutable: 3]

  alias Ecto.Changeset
  alias KineticEcto.TestImage, as: Image

  describe "validate_immutable/3" do
    test "[PASS] allows an unset (nil) value to be set" do
      assert %Changeset{valid?: true} =
               %{}
               |> Image.changeset()
               |> put_color()
               |> validate_immutable(:color)
    end

    test "[PASS] allows a blank value to be set" do
      assert %Changeset{valid?: true} =
               %Image{color: ""}
               |> Image.changeset(%{})
               |> put_color()
               |> validate_immutable(:color)
    end

    test "[PASS] allows a changeset with the same value to pass" do
      assert %Changeset{valid?: true} =
               %Image{color: "#fff"}
               |> Image.changeset(%{})
               |> put_color()
               |> validate_immutable(:color)
    end

    test "[FAIL] disallows a set value from being changed" do
      assert %Changeset{valid?: false, errors: errors} =
               %Image{color: "#eee"}
               |> Image.changeset(%{})
               |> put_color()
               |> validate_immutable(:color, message: "has been fixed")

      assert [color: {"has been fixed", immutable: true, validation: :immutable}] = errors
    end

    test "[FAIL] works with multiple fields reporting errors only on failed fields" do
      image =
        %{
          color: "#eee",
          url: "https://example.com",
          rgba: %{red: 0.9, green: 0.8, blue: 0.7, alpha: 0.3},
          hsla: %{hue: 0.5, saturation: 0.7, luminance: 0.4, alpha: 0.2}
        }
        |> Image.changeset()
        |> Changeset.apply_changes()

      changeset =
        image
        |> Image.changeset(%{})
        |> put_color()
        |> put_url()
        |> put_rgba()
        |> put_hsla()
        |> validate_immutable([:color, :hsla])

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert {"cannot be changed once set", immutable: true, validation: :immutable} =
               Keyword.get(errors, :color)

      assert {"cannot be changed once set", immutable: true, validation: :immutable} =
               Keyword.get(errors, :hsla)
    end

    defp put_color(changeset), do: Changeset.put_change(changeset, :color, "#fff")
    defp put_url(changeset), do: Changeset.put_change(changeset, :url, "https://example.com")
    defp put_rgba(changeset), do: Changeset.put_embed(changeset, :rgba, %{red: 0.9, green: 0.8, blue: 0.7, alpha: 0.3})

    defp put_hsla(changeset),
      do: Changeset.put_embed(changeset, :hsla, %{hue: 0.9, saturation: 0.8, luminance: 0.7, alpha: 0.3})
  end
end
