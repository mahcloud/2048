defmodule TwentyWeb.PageLive do
  use TwentyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, reset_socket(%{ socket: socket })}
  end

  @impl true
  def handle_event("create_form_name", %{"name" => name}, socket) do
    {:ok, %{socket_params: %{name: name}, socket: socket}}
    |> reply()
  end
  def handle_event("create", %{"name" => name}, socket) do
    {:ok, %{socket_params: %{name: name}, socket: socket}}
    |> validate_name()
    |> create_game()
    |> clear_name()
    |> reply()
  end

  ###
  ### PRIVATE
  ###

  defp clear_name({:ok, %{socket_params: socket_params, socket: socket}}) do
    {:ok, %{socket_params: socket_params |> Map.delete(:name), socket: socket }}
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

  defp reply({:ok, %{socket_params: %{games: _games, name: _name} = socket_params, socket: socket}}) do
    {:noreply, socket |> assign(socket_params)}
  end
  defp reply({:error, %{error: error, socket_params: %{games: _games, name: _name} = socket_params, socket: socket}}) do
    socket = socket
    |> put_flash(:error, error)
    |> assign(socket_params)
    {:noreply, socket}
  end
  defp reply({:error, %{socket_params: %{games: _games, name: _name}, socket: _socket} = params}) do
    reply({:error, params |> Map.put(:error, "Something went wrong")})
  end
  defp reply({status, %{socket_params: %{games: _games} = socket_params} = params}) do
    reply({status, params |> Map.put(:socket_params, socket_params |> Map.put(:name, ""))})
  end
  defp reply({status, %{socket_params: socket_params} = params}) do
    reply({status, params |> Map.put(:socket_params, socket_params |> Map.put(:games, get_games()))})
  end

  defp validate_name({:ok, %{socket_params: %{name: nil}} = params}) do
    {:error, params |> Map.put(:error, "Name is required")}
  end
  defp validate_name({:ok, %{socket_params: %{name: ""}} = params}) do
    {:error, params |> Map.put(:error, "Name is required")}
  end
  defp validate_name({:ok, %{socket_params: %{name: name}} = params}) do
    case String.trim(name) do
      "" -> {:error, params |> Map.put(:error, "Name is required")}
      _ -> {:ok, params}
    end
  end

  defp reset_socket(%{ socket: socket }) do
    socket
    |> assign(%{games: get_games(), name: ""})
  end
end
