defmodule PhoenixLogbaseApiWeb.ApiResponseBuilder do
  @moduledoc """
  A helper module to build API responses in a consistent format.
  """

  # builds links for HATEOAS responses. If `self` is a string, it creates a map with a single `self` key.
  defp build_links(self) when is_bitstring(self) do
    %{self: self}
  end

  # builds links for HATEOAS responses. If `links` is a map, it validates that all values are strings.
  defp build_links(%{self: _} = links) when is_map(links) do
    true = Enum.all?(links, fn {_key, value} -> is_bitstring(value) end)
    links
  end

  # Builds a basic response with a code and optional data.
  # links is a required parameter to ensure that all responses include HATEOAS links, even if they are empty.
  defp build_response(links, data, code \\ 0) do
    response = %{code: code, links: build_links(links)}

    if data do
      Map.put(response, :response, data)
    else
      response
    end
  end

  @doc """
  Builds a success response with the given data.

  ## Examples

      iex> PhoenixLogbaseApi.ApiResponseBuilder.build_success(%{id: 1, name: "Test"})
      %{status: "success", data: %{id: 1, name: "Test"}}

  """
  @spec build_success(any(), bitstring() | %{:self => any(), optional(any()) => any()}) :: %{
          :code => 0,
          :links => %{:self => any(), optional(any()) => any()},
          optional(:response) => any()
        }
  def build_success(data, links), do: build_response(links, data)

  @doc """
  Builds an error response with the given message and optional details.

  ## Examples

      iex> PhoenixLogbaseApi.ApiResponseBuilder.build_error("Something went wrong")
      %{status: "error", message: "Something went wrong"}

      iex> PhoenixLogbaseApi.ApiResponseBuilder.build_error("Validation failed", %{field: "email"})
      %{status: "error", message: "Validation failed", details: %{field: "email"}}

  """
  @spec build_error(
          maybe_improper_list(),
          bitstring() | %{:self => any(), optional(any()) => any()}
        ) :: %{
          :code => 0,
          :errors => maybe_improper_list(),
          :links => %{:self => any(), optional(any()) => any()},
          optional(:response) => any()
        }
  def build_error(code \\ 500, errors, links) when is_list(errors) do
    Map.put(build_response(links, nil, code), :errors, errors)
  end
end
