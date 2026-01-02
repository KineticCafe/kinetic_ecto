if Code.loaded?(Postgrex) && Code.loaded?(Ecto.Adapters.SQL) do
  defmodule KineticEcto.Postgres.Trigram do
    @moduledoc """
    Macros that simulate PostgreSQL functions using Ecto fragments expanded in Ecto
    queries for use with [pgtrgm][1] for trigram similarity searches.

    This module is only present if [ecto_sql][2] and [postgrex][3] are loaded.

    [1]: https://www.postgresql.org/docs/current/pgtrgm.html
    [2]: https://hex.pm/packages/ecto_sql
    [3]: https://hex.pm/packages/postgrex
    """

    @doc """
    Performs a similarity comparison using the `%` operator returning a boolean value.

    > `left_text % right_text → boolean`
    >
    > Returns `true` if its arguments have a similarity that is greater than the
    > current similarity threshold set by `pg_trgm.similarity_threshold`.

    Provided by the pgtrgm extension.
    """
    defmacro similar_to(left_text, right_text) do
      quote do
        fragment("? % ?", unquote(left_text), unquote(right_text))
      end
    end

    @doc """
    Returns a real number representing the similarity of the two arguments.

    > similarity (text, text) → real
    >
    > Returns a number that indicates how similar the two arguments are. The
    > range of the result is zero (indicating that the two strings are completely
    > dissimilar) to one (indicating that the two strings are identical).

    Provided by the pgtrgm extension.
    """
    defmacro similarity(left_text, right_text) do
      quote do
        fragment("similarity(?, ?)", unquote(left_text), unquote(right_text))
      end
    end

    @doc """
    Returns a real number representing the whole word similarity of the two
    arguments.

    > strict_word_similarity (text, text) → real
    >
    > Same as `word_similarity`, but forces extent boundaries to match word
    > boundaries. Since we don't have cross-word trigrams, this function actually
    > returns greatest similarity between first string and any continuous extent
    > of words of the second string.

    Provided by the pgtrgm extension.
    """
    defmacro strict_word_similarity(left_text, right_text) do
      quote do
        fragment("strict_word_similarity(?, ?)", unquote(left_text), unquote(right_text))
      end
    end
  end
end
