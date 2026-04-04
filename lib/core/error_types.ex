defmodule PhoenixLogbaseApiWeb.ApiError do
  @moduledoc """
  Defines the structure of API errors.
  """
  @derive Jason.Encoder
  defstruct [:code, :error_type, :status_code, :message]
end

defmodule PhoenixLogbaseApiWeb.ErrorTypes do
  use Constant
  alias PhoenixLogbaseApiWeb.ApiError, as: ApiError

  # 1xxxx for internal errors
  constant unexpected_error, %ApiError{code: 10000, status_code: 500, error_type: "unexpected_error", message: "Unexpected error"}

  # 2xxxx for user errors
  constant validation_error, %ApiError{code: 20000, status_code: 400, error_type: "validation", message: "Validation error"}
  constant not_found,        %ApiError{code: 20001, status_code: 404, error_type: "not_found", message: "Resource not found"}

end
