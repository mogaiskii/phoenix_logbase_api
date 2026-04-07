defmodule PhoenixLogbaseApiWeb.ErrorJSONTest do
  use PhoenixLogbaseApiWeb.ConnCase, async: true

  test "renders default 404" do
    assert PhoenixLogbaseApiWeb.ErrorJSON.render("404.json", %{}) == %{errors: ["Not Found"], code: 404, links: %{self: ""}}
  end

  test "renders default 500" do
    assert PhoenixLogbaseApiWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: ["Internal Server Error"], code: 500, links: %{self: ""}}
  end
end
