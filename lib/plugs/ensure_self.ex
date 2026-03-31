if Code.ensure_loaded(Plug) do
  defmodule PhoenixLogbaseApiWeb.EnsureSelf do
    @moduledoc """
    A plug to ensure that the `self` link is present in the response.
    """

    import Plug.Conn

    def init(opts), do: opts

    @doc """
    Ensures that the `self` link is present in the response.
    """
    def call(conn, _opts) do
      register_before_send(conn, fn conn ->
        resp(
          conn,
          conn.status,
          Jason.encode!(put_in(Jason.decode!(IO.iodata_to_binary(conn.resp_body), keys: :atoms), [:links, :self], conn.request_path || ""))
        )
      end )
    end
  end
end
