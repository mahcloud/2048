defmodule TwentyWeb.GamesLive do
  use TwentyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(%{games: get_games(), name: ""})}
  end

  @impl true
  def handle_event("create_form_name", %{"name" => name}, socket) do
    {:ok, %{socket: socket, socket_params: %{name: name}}}
    |> reply()
  end
  def handle_event("create", %{"name" => name}, socket) do
    {:ok, %{socket: socket, socket_params: %{name: name}}}
    |> validate_required()
    |> validate_unique()
    |> create_game()
    |> redirect()
    |> clear_name()
    |> reply()
  end

  ###
  ### PRIVATE
  ###

  defp clear_name({:ok, %{socket: socket, socket_params: socket_params}}) do
    {:ok, %{socket: socket, socket_params: socket_params |> Map.delete(:name)}}
  end
  defp clear_name(params), do: params

  defp create_game({:ok, %{socket_params: %{name: name}} = params}) do
    pid = Process.whereis(:games)
    Twenty.Games.start_game(pid, name)

    {:ok, params}
  end
  defp create_game(params), do: params

  defp get_games() do
    pid = Process.whereis(:games)
    Twenty.Games.get_games(pid)
  end

  defp redirect({:ok, %{socket: socket, socket_params: %{name: name}} = params}) do
    {:ok, params |> Map.put(:socket, socket |> redirect(to: "/games/#{name}"))}
  end
  defp redirect(params), do: params

  defp reply({:ok, %{socket: socket, socket_params: %{games: _games, name: _name} = socket_params}}) do
    {:noreply, socket |> assign(socket_params)}
  end
  defp reply({:error, %{error: error, socket: socket, socket_params: %{games: _games, name: _name} = socket_params}}) do
    socket = socket
    |> put_flash(:error, error)
    |> assign(socket_params)
    {:noreply, socket}
  end
  defp reply({:error, %{socket: _socket, socket_params: %{games: _games, name: _name}} = params}) do
    reply({:error, params |> Map.put(:error, "Something went wrong")})
  end
  defp reply({status, %{socket_params: %{games: _games} = socket_params} = params}) do
    reply({status, params |> Map.put(:socket_params, socket_params |> Map.put(:name, ""))})
  end
  defp reply({status, %{socket_params: socket_params} = params}) do
    reply({status, params |> Map.put(:socket_params, socket_params |> Map.put(:games, get_games()))})
  end

  defp validate_required({:ok, %{socket_params: %{name: nil}} = params}) do
    {:error, params |> Map.put(:error, "Name is required")}
  end
  defp validate_required({:ok, %{socket_params: %{name: ""}} = params}) do
    {:error, params |> Map.put(:error, "Name is required")}
  end
  defp validate_required({:ok, %{socket_params: %{name: name} = socket_params} = params}) do
    String.trim(name)
    |> case do
      "" -> {:error, params |> Map.put(:error, "Name is required")}
      trimmed_name -> {:ok, params |> Map.put(:socket_params, socket_params |> Map.put(:name, trimmed_name))}
    end
  end

  defp validate_unique({:ok, %{socket_params: %{name: name}} = params}) do
    get_games()
    |> Enum.map(fn {_pid, game_name} -> game_name end)
    |> Enum.member?(name)
    |> case do
      false -> {:ok, params}
      _ -> {:error, params |> Map.put(:error, "Name is already taken")}
    end
  end
end
