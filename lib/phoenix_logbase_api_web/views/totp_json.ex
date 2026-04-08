defmodule PhoenixLogbaseApiWeb.TotpJSON do
  import PhoenixLogbaseApiWeb.ApiResponseBuilder, only: [build_success: 2]

  def request(%{url: url, links: links}) do
    build_success(%{totp_link: url}, links)
  end

  def confirm(%{links: links}) do
    build_success(%{}, links)
  end

  def remove(%{links: links}) do
    build_success(%{}, links)
  end
end
