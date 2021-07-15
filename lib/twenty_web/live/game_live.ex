defmodule TwentyWeb.GameLive do
  use TwentyWeb, :live_view

  @impl true
  def mount(%{"name" => name}, _session, socket) do
    {:ok, %{name: name, socket: socket, source: :mount}}
    |> get_board_by_name()
    |> reply()
  end

  @impl true
  def handle_event("left", _form, %{assigns: %{name: name}} = socket) do
    {:ok, %{direction: "left", name: name, socket: socket, source: :event}}
    |> handle_move()
  end
  def handle_event("up", _form, %{assigns: %{name: name}} = socket) do
    {:ok, %{direction: "up", name: name, socket: socket, source: :event}}
    |> handle_move()
  end
  def handle_event("down", _form, %{assigns: %{name: name}} = socket) do
    {:ok, %{direction: "down", name: name, socket: socket, source: :event}}
    |> handle_move()
  end
  def handle_event("right", _form, %{assigns: %{name: name}} = socket) do
    {:ok, %{direction: "right", name: name, socket: socket, source: :event}}
    |> handle_move()
  end

  ###
  ### PRIVATE
  ###

  defp get_board_by_name({:ok, %{name: name, socket: socket} = params}) do
    socket_params = %{name: name}
    params = params
    |> Map.put(:socket_params, socket_params)

    get_game_pid_by_name(name)
    |> case do
      nil ->
        socket = socket
        |> redirect(to: "/games")

        {:error, params |> Map.put(:error, "Game not found") |> Map.put(:socket, socket)}
      game_pid -> 
        board = get_board_by_pid(game_pid)

        socket_params = socket_params
        |> Map.put(:board, board)

        params = params
        |> Map.put(:socket_params, socket_params)
        |> Map.put(:game_pid, game_pid)

        {:ok, params}
    end
  end
  defp get_board_by_name(params), do: params

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

  defp handle_move(params) do
    params
    |> get_board_by_name()
    |> move()
    |> get_board_by_name()
    |> reply()
  end

  defp move({:ok, %{direction: direction, game_pid: game_pid} = params}) do
    Twenty.Game.combine(game_pid, get_direction_atom(direction))
    |> case do
      {:ok, _} ->
        Twenty.Game.increment(game_pid)
        |> case do
          {:ok, _} -> {:ok, params}
          {:error, error} -> {:error, params |> Map.put(:error, error)}
        end
      {:error, error} -> {:error, params |> Map.put(:error, error)}
    end
  end
  defp move(params), do: params

  defp reply({:ok, %{socket: socket, socket_params: %{board: _board, name: _name} = socket_params, source: source}}) do
    socket = socket
    |> assign(socket_params)

    source
    |> case do
      :mount -> {:ok, socket}
      _ -> {:noreply, socket}
    end
  end
  defp reply({:error, %{error: error, socket: socket, socket_params: %{board: _board, name: _name} = socket_params, source: source}}) do
    socket = socket
    |> put_flash(:error, error)
    |> assign(socket_params)

    source
    |> case do
      :mount -> {:ok, socket}
      _ -> {:noreply, socket}
    end
  end
  defp reply({status, %{socket_params: socket_params} = params}) do
    reply({status, params |> Map.put(:socket_params, socket_params |> Map.put(:board, []))})
  end
  defp reply({:error, %{socket: _socket} = params}) do
    reply({:error, params |> Map.put(:error, "Something went wrong")})
  end
end
