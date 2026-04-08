defmodule PhoenixLogbaseApiWeb.AuthFallbackController do
  use PhoenixLogbaseApiWeb, :controller

  alias PhoenixLogbaseApiWeb.ErrorTypes, as: ErrorTypes

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    case type do
      :invalid_token -> render_errors(conn, ErrorTypes.invalid_token())
      :expired_token -> render_errors(conn, ErrorTypes.expired_token())
      _ -> render_errors(conn, ErrorTypes.unauthorized())
    end
  end

  # TODO: copipaste from FallbackController, consider refactoring to avoid duplication
  defp render_errors(conn, api_error, errors \\ nil) do
    conn
    |> put_status(api_error.status_code)
    |> put_resp_content_type("application/json")
    |> put_view(json: PhoenixLogbaseApiWeb.ErrorJSON)
    |> render(
      "#{api_error.status_code}.json",
      self: conn.request_path || "",
      code: api_error.code,
      errors: errors || [%{"message" => api_error.message, "code" => api_error.code}]
      )
  end
end
