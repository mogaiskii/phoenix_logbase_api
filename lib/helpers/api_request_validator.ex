defmodule PhoenixLogbaseApiWeb.ApiRequestValidator do
  @moduledoc """
  A module to validate API requests against JSON schemas.
  """

  alias ExJsonSchema.Validator

  def validate_request(params, schema) do
    case Validator.validate(schema, params, error_formatter: PhoenixLogbaseApiWeb.ApiRequestValidator) do
      :ok -> {:ok, params}
      {:error, errors} -> {:error, errors}
    end
  end

  # TODO: align with unified format
  def format(errors) do
    ExJsonSchema.Validator.Error.StringFormatter.format(errors)
  end
end
