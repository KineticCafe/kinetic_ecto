defmodule KineticEcto.TestImage do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  schema "images" do
    field :url, :string
    field :color, :string

    embeds_one :rgba, RGBA, on_replace: :delete, primary_key: false do
      field :red, :float
      field :green, :float
      field :blue, :float
      field :alpha, :float
    end

    embeds_one :hsla, HSLA, on_replace: :delete, primary_key: false do
      field :hue, :float
      field :saturation, :float
      field :luminance, :float
      field :alpha, :float
    end
  end

  def changeset(image \\ %__MODULE__{}, attrs) do
    image
    |> cast(attrs, [:url, :color])
    |> cast_embed(:rgba, with: &rgba_changeset/2)
    |> cast_embed(:hsla, with: &hsla_changeset/2)
  end

  def rgba_changeset(rgba \\ %__MODULE__{}, attrs) do
    rgba
    |> cast(attrs, [:red, :green, :blue, :alpha])
    |> validate_required([:red, :green, :blue, :alpha])
  end

  def hsla_changeset(hsla \\ %__MODULE__{}, attrs) do
    hsla
    |> cast(attrs, [:hue, :saturation, :luminance, :alpha])
    |> validate_required([:hue, :saturation, :luminance, :alpha])
  end
end
