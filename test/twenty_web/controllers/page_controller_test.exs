defmodule TwentyWeb.PageControllerTest do
  use TwentyWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "2048"
  end
end
