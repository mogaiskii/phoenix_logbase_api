defmodule PhoenixLogbaseApiWeb.ApiErrorHandler do
  @moduledoc """
  A module to handle API errors and return JSON responses.
  """

  import PhoenixLogbaseApiWeb.ApiResponseBuilder, only: [build_error: 3]

  @doc """
  Handles errors by returning a JSON response with a 500 status code.
  """
  def handle_errors(conn, %{kind: :error, reason: %{plug_status: status, message: msg}}), do: Plug.Conn.send_resp(conn, status, Jason.encode!(build_error(status, [msg], conn.request_path || "")))
  def handle_errors(conn, %{kind: :throw}), do: Plug.Conn.send_resp(conn, 500, Jason.encode!(build_error(500, ["Unexpected exception"], conn.request_path || "")))
  def handle_errors(conn, _opts), do: Plug.Conn.send_resp(conn, 500, Jason.encode!(build_error(500, ["Unexpected error"], conn.request_path || "")))

  def handle_no_route(conn), do: Plug.Conn.send_resp(conn, 404, Jason.encode!(build_error(404, ["Route not found"], conn.request_path || "")))
end
