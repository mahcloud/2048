defmodule TwentyWeb.PageLiveTest do
  use TwentyWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, games_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to 2048!"
    assert render(games_live) =~ "Welcome to 2048!"
  end
end
