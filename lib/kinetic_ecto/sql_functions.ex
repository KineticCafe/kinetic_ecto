if Code.loaded?(Ecto.Adapters.SQL) do
  defmodule KineticEcto.SQLFunctions do
    @moduledoc """
    Macros that simulate SQL functions using Ecto fragments that are expanded in Ecto
    queries.

    This module is only available when using [ecto_sql][1], but the functions should work
    regardless of the SQL driver.

    [1]: https://hex.pm/packages/ecto_sql
    """

    @doc "Joins two string values together using the `||` operator."
    defmacro join_str(left, right, joiner \\ " ") do
      quote do
        fragment("? || ? || ?", unquote(left), unquote(joiner), unquote(right))
      end
    end

    @doc "Calls `round(avg(column), digits)`."
    defmacro rounded_average(column, digits \\ 2) do
      quote do
        fragment("round(avg(?), ?)", unquote(column), ^unquote(digits))
      end
    end

    @doc "Calls `nullif(column, match)`."
    defmacro nullif(column, match) do
      quote do
        fragment("nullif(?, ?)", unquote(column), ^unquote(match))
      end
    end

    @doc "Calls `round(column, digits)`."
    defmacro round(column, digits \\ 2) do
      quote do
        fragment("round(?, ?)", unquote(column), ^unquote(digits))
      end
    end
  end
end
