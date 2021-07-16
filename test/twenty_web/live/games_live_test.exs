defmodule TwentyWeb.PageLiveTest do
  use TwentyWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, games_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to 2048!"
    assert render(games_live) =~ "Welcome to 2048!"
  end

  test "create invalid game no name", %{conn: conn} do
    {:ok, games_live, _} = live(conn, "/")
    html = games_live
    |> form("#game-form", %{game_schema: %{name: ""}})
    |> render_submit()

    assert html =~ "is required"
  end

  test "create invalid game empty name", %{conn: conn} do
    {:ok, games_live, _} = live(conn, "/")
    html = games_live
    |> form("#game-form", %{game_schema: %{name: "    "}})
    |> render_submit()

    assert html =~ "is required"
  end

  test "create valid game", %{conn: conn} do
    {:ok, games_live, _} = live(conn, "/")
    {:error, {:redirect, %{to: redirect_to}}} = games_live
    |> form("#game-form", %{game_schema: %{name: "test"}})
    |> render_submit()

    assert redirect_to == "/games/test"
  end

  test "create valid game should trim", %{conn: conn} do
    {:ok, games_live, _} = live(conn, "/")
    {:error, {:redirect, %{to: redirect_to}}} = games_live
    |> form("#game-form", %{game_schema: %{name: "foobar    "}})
    |> render_submit()

    assert redirect_to == "/games/foobar"
  end

  test "create duplicate game", %{conn: conn} do
    pid = Process.whereis(:games)
    Twenty.Games.start_game(pid, "duplicate")

    {:ok, games_live, _} = live(conn, "/")
    html = games_live
    |> form("#game-form", %{game_schema: %{name: "duplicate"}})
    |> render_submit()

    assert html =~ "already taken"
  end

  test "create duplicate game with spaces", %{conn: conn} do
    pid = Process.whereis(:games)
    Twenty.Games.start_game(pid, "duplicate")

    {:ok, games_live, _} = live(conn, "/")
    html = games_live
    |> form("#game-form", %{game_schema: %{name: "   duplicate  "}})
    |> render_submit()

    assert html =~ "already taken"
  end
end
