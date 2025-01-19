defmodule KineticEcto do
  @moduledoc """
  Documentation for `KineticEcto`.
  """

  @doc """
  Returns true if the value would be considered empty.

  | value type    | result                             |
  | ------------- | ---------------------------------- |
  | `nil`         | `true`                             |
  | binary        | `String.trim_leading(value) == ""` |
  | list          | `value == []`                      |
  | tuple         | `tuple_size(value) == 0`           |
  | map           | `map_size(value) == 0`             |
  | Enumerable    | `Enum.empty?(value)`               |
  | anything else | `false`                            |

  - `nil` is empty
  - non-struct maps are empty if `map_size/1` is `0`
  - lists are empty if they equal `[]`
  - strings are empty if, when trimmed of leading spaces, they are equal to an
    empty string (`""`)
  - values implementing the `Enumerable` protocol are empty if `Enum.empty?/1`
    returns `true`
  - all other values are not empty

  ### Examples

  iex> KineticEcto.empty?(nil)
  true

  iex> KineticEcto.empty?("")
  true

  iex> KineticEcto.empty?([])
  true

  iex> KineticEcto.empty?("   ")
  true

  iex> KineticEcto.empty?(" xyz ")
  false

  iex> KineticEcto.empty?(MapSet.new([]))
  true

  iex> KineticEcto.empty?([1])
  false

  iex> KineticEcto.empty?(1..1//1)
  false

  iex> KineticEcto.empty?(%{})
  true

  iex> KineticEcto.empty?(%{a: 1})
  false

  iex> KineticEcto.empty?({})
  true

  iex> KineticEcto.empty?({1})
  false
  """
  def empty?(nil), do: true
  def empty?(""), do: true
  def empty?([]), do: true
  def empty?({}), do: true
  def empty?(value) when is_binary(value), do: String.trim_leading(value) == ""
  def empty?(value) when is_list(value), do: false

  def empty?(value) do
    cond do
      Enumerable.impl_for(value) -> Enum.empty?(value)
      is_struct(value) -> false
      is_map(value) -> map_size(value) == 0
      true -> false
    end
  end

  @doc """
  Returns true if the value would not be considered empty. See `empty?/1` for
  details.

  ### Examples

  iex> KineticEcto.present?(nil)
  false

  iex> KineticEcto.present?("")
  false

  iex> KineticEcto.present?([])
  false

  iex> KineticEcto.present?("   ")
  false

  iex> KineticEcto.present?(" xyz ")
  true

  iex> KineticEcto.present?(MapSet.new([]))
  false

  iex> KineticEcto.present?([1])
  true

  iex> KineticEcto.present?(1..1//1)
  true

  iex> KineticEcto.present?(%{})
  false

  iex> KineticEcto.present?(%{a: 1})
  true

  iex> KineticEcto.present?({})
  false

  iex> KineticEcto.present?({1})
  true
  """
  def present?(value), do: !empty?(value)
end
