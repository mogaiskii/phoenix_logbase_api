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

  def call(conn, {:error, :not_found}), do: render_errors(conn, ErrorTypes.not_found())
  def call(conn, {:error, %Ecto.NoResultsError{}}), do: render_errors(conn, ErrorTypes.not_found())

  @spec handle_errors(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def handle_errors(conn, %{kind: :error, reason: %Ecto.NoResultsError{}}), do: render_errors(conn, ErrorTypes.not_found())
  def handle_errors(conn, %{kind: :error, reason: %{message: msg}}), do: render_errors(conn, ErrorTypes.unexpected_error(), [msg])
  def handle_errors(conn, %{kind: :throw}), do: render_errors(conn, ErrorTypes.unexpected_error())
  def handle_errors(conn, _opts), do: render_errors(conn, ErrorTypes.unexpected_error())

  def route_not_found(conn), do: render_errors(conn, ErrorTypes.not_found())

  defp render_errors(conn, api_error, errors \\ nil) do
    conn
    |> put_status(api_error.status_code)
    |> put_resp_content_type("application/json")
    |> put_view(json: PhoenixLogbaseApiWeb.ErrorJSON)
    |> render(
      "#{api_error.status_code}.json",
      self: conn.request_path || "",
      code: api_error.code,
      errors: errors || [api_error.message]
      )
  end

end
