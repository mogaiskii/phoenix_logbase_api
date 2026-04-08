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

  # 3xxxx for authentication/authorization errors
  constant invalid_token,    %ApiError{code: 30000, status_code: 401, error_type: "invalid_token", message: "Invalid token"}
  constant expired_token,    %ApiError{code: 30001, status_code: 401, error_type: "expired_token", message: "Expired token"}
  constant unauthorized,     %ApiError{code: 30002, status_code: 401, error_type: "unauthorized", message: "Unauthorized"}
  constant invalid_password, %ApiError{code: 30003, status_code: 401, error_type: "invalid_password", message: "Invalid password"}

end
