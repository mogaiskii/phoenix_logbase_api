defmodule PhoenixLogbaseApiWeb.ChangesetJSON do
  import PhoenixLogbaseApiWeb.ErrorTypes, only: [validation_error: 0]

  @doc """
  Renders changeset errors.
  """
  @spec changeset_error(Ecto.Changeset.t()) :: list()
  def changeset_error(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    |> flatten_errors()
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  defp flatten_errors(errors, path \\ []) when is_map(errors) do
    errors
    |> Enum.map(fn {field, field_errors} ->
      if is_map(field_errors) do
        %{type: validation_error(), field: field, path: path, inner: flatten_errors(field_errors, [path] ++ [field])}
      else
        %{type: validation_error(), field: field, path: path, errors: field_errors}
      end
    end)
  end
end
