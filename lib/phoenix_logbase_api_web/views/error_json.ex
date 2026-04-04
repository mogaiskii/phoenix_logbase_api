defmodule PhoenixLogbaseApiWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  import PhoenixLogbaseApiWeb.ApiResponseBuilder, only: [build_error: 3]

  def render(_template, %{code: code, errors: errors, self: self}) when is_integer(code) and is_list(errors) and is_bitstring(self) do
    build_error(code, errors, self)
  end

  def render(template, _assigns), do: build_error(status_code_from_template(template), [Phoenix.Controller.status_message_from_template(template)], "")  # empty string here, as we cannot access the request context to build links in this error renderer

  defp status_code_from_template(template) do
    template
    |> String.split(".")
    |> hd()
    |> String.to_integer()
  rescue
    _ -> 500
  end

end
