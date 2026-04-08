defmodule PhoenixLogbaseApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use PhoenixLogbaseApiWeb, :controller
  import PhoenixLogbaseApiWeb.ChangesetJSON, only: [changeset_error: 1]
  alias PhoenixLogbaseApiWeb.ErrorTypes, as: ErrorTypes

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    render_errors(conn, ErrorTypes.validation_error(), [changeset_error(changeset)])
  end

  def call(conn, {:error, %Ecto.NoResultsError{}}), do: render_errors(conn, ErrorTypes.not_found())

  def call(conn, {:error, :invalid_token_type}), do: render_errors(conn, ErrorTypes.invalid_token())
  def call(conn, {:error, error}) when is_atom(error), do: render_errors(conn, resolve_error(error))

  def call(conn, :route_not_found), do: render_errors(conn, ErrorTypes.not_found())

  def call(conn, _opts), do: render_errors(conn, ErrorTypes.unexpected_error())

  @spec handle_errors(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def handle_errors(conn, %{kind: :error, reason: %Ecto.NoResultsError{}}), do: render_errors(conn, ErrorTypes.not_found())
  def handle_errors(conn, %{kind: :error, reason: %{message: msg}}), do: render_errors(conn, ErrorTypes.unexpected_error(), [msg])
  def handle_errors(conn, %{kind: :throw}), do: render_errors(conn, ErrorTypes.unexpected_error())
  def handle_errors(conn, _opts), do: render_errors(conn, ErrorTypes.unexpected_error())

  defp resolve_error(error) when is_atom(error) do
    case ErrorTypes.implemented?(error) do
      true  -> apply(ErrorTypes, error, [])
      false -> ErrorTypes.unexpected_error()
    end
  end

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
