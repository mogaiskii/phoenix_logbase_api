defmodule PhoenixLogbaseApiWeb.ApiRequestValidator do
  @moduledoc """
  A module to validate API requests against JSON schemas.
  """

  alias ExJsonSchema.Validator
  import PhoenixLogbaseApiWeb.ErrorTypes, only: [validation_error: 0]

  def validate_request(params, schema) do
    case Validator.validate(schema, params, error_formatter: PhoenixLogbaseApiWeb.ApiRequestValidator) do
      :ok -> {:ok, params}
      {:error, errors} -> {:error, errors}
    end
  end

  # TODO: align with unified format
  def format(errors) do
    err_format_map = Enum.zip(errors, ExJsonSchema.Validator.Error.StringFormatter.format(errors))
    List.flatten(Enum.map(err_format_map, &format_error/1))
  end

  defp format_error({%ExJsonSchema.Validator.Error{error: %ExJsonSchema.Validator.Error.Required{missing: missing}, path: path}, _}) do
    Enum.map(missing, fn field ->
      %{message: "Missing required field '#{field}'", code: validation_error().code, path: make_path(path, field)}
    end)
  end

  defp format_error({%ExJsonSchema.Validator.Error{path: path}, {text, _}}) do
    %{message: text, code: validation_error().code, path: make_path(path)}
  end

  # path: string in format of "#/field1/field2", field: string, returns string in format of "field1.field2.field"
  defp make_path(path, field \\ nil) do
    path
    |> String.trim_leading("#")
    |> String.trim_leading("/")  # splitted in two lines specifically for root-level fields
    |> String.split("/", trim: true)
    |> Enum.concat(if field, do: [field], else: [])
    |> Enum.join(".")
  end

end
