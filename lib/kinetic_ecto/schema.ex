defmodule KineticEcto.Schema do
  @moduledoc """
  Useful functions for working with Ecto schemas.

  Provides a helper function for getting a list of fields from a schema, suitable for use
  in an  `on_conflict` clause using `{:replace, fields}` for [upserts][1].

  [1]: https://hexdocs.pm/ecto/Ecto.Repo.html#c:insert/2-upserts
  """

  @doc """
  Returns the list of fields for the `schema`.

  ### Options

  - `:except`: Excludes the fields listed. Must be the atom field names, or two special
    values (these are 1-tuples to prevent them from conflicting with existing field names):

    - `{:primary_key}`: excludes the schema's primary key
    - `{:insert_only}`: excludes the schema's primary key and `inserted_at`.
  """
  def fields(schema, opts \\ [])

  def fields(schema, []), do: schema.__schema__(:fields)

  def fields(schema, opts) do
    except =
      opts
      |> Keyword.get(:except, [])
      |> List.flatten()
      |> Enum.flat_map(fn
        {:primary_key} -> schema.__schema__(:primary_key)
        {:insert_only} -> [:inserted_at | schema.__schema__(:primary_key)]
        value -> [value]
      end)

    schema.__schema__(:fields) -- except
  end

  @doc """
  Returns a `{:replace, fields}` tuple suitable for use in an insertion conflict clause.

  See `fields/2` and `Ecto.Repo.insert/2`.
  """
  def replace(schema, options \\ []), do: {:replace, fields(schema, options)}

  @doc """
  When `use KineticEcto.Schema` is applied to a schema definition, it adds `__fields__/`
  and `__replace__/1` to provide implicit calls to `KineticEcto.Schema.fields/2` and
  `KineticEcto.Schema.replace/2` with the schema module provided.
  """
  defmacro __using__(_opts) do
    quote do
      alias KineticEcto.Schema

      @doc """
      Returns the list of fields for the schema, `:except` for the fields
      specified. See `KineticEcto.Schema.fields/2`.
      """
      def __fields__(options \\ []), do: Schema.fields(__MODULE__, options)

      @doc """
      Returns a `{:replace, fields}` tuple suitable for use in an insertion
      conflict clause. See `KineticEcto.Schema.replace/2`.
      """
      def __replace__(options \\ []), do: Schema.replace(__MODULE__, options)
    end
  end
end
