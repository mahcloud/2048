defmodule TwentyWeb.GamesController do
  use TwentyWeb, :controller

  def index(conn, _params) do
    games = get_games()
    render(conn, "index.html", %{games: games})
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"name" => name }) do
    pid = Process.whereis(:games)
    Twenty.Games.start_game(pid, name)

    conn
    |> redirect(to: "/games/#{name}") |> halt()
  end

  def view(conn, %{"name" => name}) do
    get_board_by_name(name)
    |> case do
      nil -> render(conn, "get.html", %{board: [], error: "Game not found"})
      board -> render(conn, "get.html", %{board: board, error: nil})
    end
  end

  def combine(conn, %{"direction" => direction, "name" => name}) do
    get_game_pid_by_name(name)
    |> case do
      nil -> render(conn, "get.html", %{board: [], error: "Game not found"})
      game_pid ->
        error = Twenty.Game.combine(game_pid, {0, 0}, get_direction_atom(direction))
        |> case do
          {:ok, _} -> nil
          {:error, e} -> e
        end
        board = get_board_by_pid(game_pid)

        render(conn, "get.html", %{board: board, error: error})
    end
  end

  ###
  ### PRIVATE
  ###

  defp get_board_by_name(name) do
    get_game_pid_by_name(name)
    |> case do
      nil -> nil
      game_pid -> get_board_by_pid(game_pid)
    end
  end

  defp get_board_by_pid(game_pid) do
    Twenty.Game.get_board(game_pid)
  end

  defp get_direction_atom("up"), do: :up
  defp get_direction_atom("down"), do: :down
  defp get_direction_atom("left"), do: :left
  defp get_direction_atom("right"), do: :right
  defp get_direction_atom(_), do: :right

  defp get_games() do
    pid = Process.whereis(:games)
    Twenty.Games.get_games(pid)
  end

  defp get_game_pid_by_name(name) do
    games = get_games()
    Enum.find(games, fn({_p_id, p_name}) -> name == p_name end)
    |> case do
      {game_pid, _name} -> game_pid
      _ -> nil
    end
  end
end
