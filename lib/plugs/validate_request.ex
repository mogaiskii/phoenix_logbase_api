defmodule PhoenixLogbaseApiWeb.ValidateRequest do
  @moduledoc """
  A plug to validate incoming API requests against JSON schemas.
  """

  import Plug.Conn
  import Phoenix.Controller, only: [put_view: 2, render: 3, action_name: 1]
  import PhoenixLogbaseApiWeb.ErrorTypes, only: [validation_error: 0]
  alias PhoenixLogbaseApiWeb.ApiRequestValidator

  def init(schema: schema, actions: actions) when is_map(schema) and is_list(actions), do: %{schema: schema, actions: actions}
  def init(_opts), do: raise(ArgumentError, "ValidateRequest plug requires a valid JSON schema in the :schema option, and a list of actions in the :actions option")

  @spec call(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def call(conn, %{schema: schema, actions: actions}) do
    if action_name(conn) in actions do
      case ApiRequestValidator.validate_request(conn.params, schema) do
        {:ok, _params} -> conn
        {:error, errors} ->
          conn
          |> put_status(validation_error().status_code)
          |> put_resp_content_type("application/json")
          |> put_view(json: PhoenixLogbaseApiWeb.ErrorJSON)
          |> render("400.json", self: conn.request_path || "", code: validation_error().code, errors: errors)
          |> halt()
      end
    else
      conn
    end
  end
end
