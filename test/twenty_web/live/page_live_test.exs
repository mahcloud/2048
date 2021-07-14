defmodule TwentyWeb.PageLiveTest do
  use TwentyWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to 2048!"
    assert render(page_live) =~ "Welcome to 2048!"
  end
end
