defmodule TwentyWeb.GamesLive do
  use TwentyWeb, :live_view

  alias Twenty.Schemas.GameSchema

  @impl true
  def mount(_params, _session, socket) do
    changeset = generate_changeset(%{})

    {:ok, socket |> assign(%{games: get_games(), game: changeset})}
  end

  @impl true
  def handle_event("validate", %{"game_schema" => game_params}, socket) do
    changeset = generate_changeset(game_params)

    socket = socket
    |> assign(:games, get_games())
    |> assign(:game, changeset)

    {:noreply, socket}
  end
  def handle_event("create", %{"game_schema" => game_params}, socket) do
    changeset = generate_changeset(game_params)
    |> Map.put(:action, :validate)

    socket
    |> assign(:games, get_games())
    |> assign(:game, changeset)
    |> create_game()
  end

  ###
  ### SOCKET
  ###

  defp create_game(%{assigns: %{game: %{valid?: is_valid} = changeset}} = socket) when is_valid == true do
    name = changeset
    |> Ecto.Changeset.get_field(:name)

    pid = Process.whereis(:games)
    Twenty.Games.start_game(pid, name)

    {:noreply, socket |> redirect(to: "/games/#{name}")}
  end
  defp create_game(socket), do: {:noreply, socket}

  ###
  ### HELPERS
  ###

  defp generate_changeset(params) do
    %GameSchema{} |> GameSchema.changeset(params)
  end

  defp get_games() do
    pid = Process.whereis(:games)
    Twenty.Games.get_games(pid)
  end
end
