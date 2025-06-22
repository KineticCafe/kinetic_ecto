defmodule KineticEcto.ChangesetValidations do
  @moduledoc """
  Additional validations for use with Ecto.Changeset.
  """

  import Ecto.Changeset
  import KineticEcto, only: [present?: 1]

  @doc """
  Validates that at least one of the `fields` is present (not `nil` or blank) in the
  `changeset`.

  `fields` must be a list of at least two schema field names.

  ### Options

  - `:minimum`: The minimum number of fields that must have a value, default `1`. The
    value provided will be clamped between `0` and the number of fields specified.
  - `:maximum`: The maximum number of fields that must have a value, default `nil`.
    Unspecified by default. If specified, will be clamped between
    specified, must be at least one and greater than or equal to `minimum` and will be
    clamped to the number of fields specified.
  - `:minimum_message`: The message to display when the `minimum` threshold of presence is
    not met.
  - `:maximum_message`: The message to display when the `maximum` threshold of presence is
    exceeded.
  - `:exact_message`: The message to display when `minimum` and `maximum` are the same
    exceeded.
  - `:message`: The message to be displayed if forwarded to `validate_required/2`.

  There are two special cases:

  - If `minimum` is the number of fields passed, this calls `validate_required/2`.
  - If `minimum` is `0` and `maximum` is unspecified, this validation will always pass.

  On validation failure, the `minimum_message` or `maximum_message` will be added to
  *each* field specified in `fields`.

  The table below shows the special cases considered.

  | Minimum     | Maximum     | Result                               |
  | ----------- | ----------- | ------------------------------------ |
  | `0`         | `nil`       | pass                                 |
  | `#fields`   | -           | `Ecto.Changeset.validate_required/3` |
  | `< 0`       | -           | `minimum = 0`                        |
  | -           | `< 1`       | `maximum = 1`                        |
  | `> #fields` | -           | `minimum = #fields`                  |
  | -           | `> #fields` | `maximum = #fields`                  |
  | -           | `< minimum` | `maximum = minimum`                  |

  """
  def validate_some_required(changeset, [_, _ | _] = fields, opts \\ []) do
    case {Keyword.get(opts, :minimum, 1), Keyword.get(opts, :maximum), Enum.count(fields)} do
      {0, nil, _} -> changeset
      {count, _, count} -> validate_required(changeset, fields, opts)
      {min, max, count} -> validate_some_required(changeset, fields, min, max, count, opts)
    end
  end

  @doc """
  Validates that the field or fields provided are not changed once set.

  If the data value (in the incoming struct) is present (not `nil` or blank), then any
  change which contains an update to that value will be rejected.
  """
  def validate_immutable(changeset, field, opts \\ [])

  def validate_immutable(changeset, fields, opts) when is_list(fields),
    do: Enum.reduce(fields, changeset, &validate_immutable(&2, &1, opts))

  def validate_immutable(changeset, field, opts) do
    # data_value? and change_value? are asymmetric because we want to permit the
    # replacement of a blank value with a non-blank value, but we do not want to permit
    # the inverse.
    data_value = Map.get(changeset.data, field)
    data_value? = present?(data_value)

    {change_value?, change_value} =
      case fetch_change(changeset, field) do
        :error -> {false, nil}
        {:ok, %Ecto.Changeset{} = embedded} -> {true, apply_changes(embedded)}
        {:ok, value} -> {true, value}
      end

    if data_value? && change_value? && data_value != change_value do
      add_error(
        changeset,
        field,
        Keyword.get(opts, :message, "cannot be changed once set"),
        immutable: true,
        validation: :immutable
      )
    else
      changeset
    end
  end

  defp field_present?(changeset, field) do
    changeset
    |> get_field(field)
    |> present?()
  end

  defp validate_some_required(changeset, fields, min, max, count, opts) when min < 0,
    do: validate_some_required(changeset, fields, 0, max, count, opts)

  defp validate_some_required(changeset, fields, min, max, count, opts) when is_integer(max) and max < 1,
    do: validate_some_required(changeset, fields, min, 1, count, opts)

  defp validate_some_required(changeset, fields, min, max, count, opts) when min > count,
    do: validate_some_required(changeset, fields, count, max, count, opts)

  defp validate_some_required(changeset, fields, min, max, count, opts) when is_integer(max) and max > count,
    do: validate_some_required(changeset, fields, min, count, count, opts)

  defp validate_some_required(changeset, fields, min, max, count, opts) when is_integer(max) and max < min,
    do: validate_some_required(changeset, fields, min, min, count, opts)

  defp validate_some_required(changeset, _fields, 0, nil, _count, _opts), do: changeset

  defp validate_some_required(changeset, fields, count, _max, count, opts),
    do: validate_required(changeset, fields, opts)

  defp validate_some_required(changeset, fields, min, max, _count, opts) do
    present = Enum.count(fields, &field_present?(changeset, &1))

    case {present < min, is_integer(max) and present > max} do
      {true, _} -> validate_some_required_errors(changeset, fields, min, max, opts, :minimum_message)
      {_, true} -> validate_some_required_errors(changeset, fields, min, max, opts, :maximum_message)
      _ -> changeset
    end
  end

  defp validate_some_required_errors(changeset, fields, min, max, opts, key) do
    default_message =
      case key do
        :minimum_message ->
          if min == 1 do
            "at least one field must be present"
          else
            "at least #{min} fields must be present"
          end

        :maximum_message ->
          if max == 1 do
            "at most one field may be present"
          else
            "at most #{max} fields may be present"
          end
      end

    message = Keyword.get(opts, key, default_message)

    details =
      if is_integer(max) do
        [minimum: min, maximum: max, fields: fields, validation: :some_required]
      else
        [minimum: min, fields: fields, validation: :some_required]
      end

    Enum.reduce(
      fields,
      changeset,
      &add_error(
        &2,
        &1,
        message,
        details
      )
    )
  end
end
