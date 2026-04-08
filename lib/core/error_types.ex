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

  def implemented?(error) when is_atom(error), do: {error, 0} in __MODULE__.__info__(:functions)

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

  constant totp_already_confirmed,  %ApiError{code: 30004, status_code: 400, error_type: "totp_already_confirmed", message: "TOTP already confirmed"}
  constant totp_not_requested,      %ApiError{code: 30005, status_code: 400, error_type: "totp_not_requested", message: "TOTP not requested"}
  constant invalid_totp_code,       %ApiError{code: 30006, status_code: 400, error_type: "invalid_totp_code", message: "Invalid TOTP code"}
  constant totp_not_enabled,        %ApiError{code: 30007, status_code: 400, error_type: "totp_not_enabled", message: "TOTP not enabled"}

end
