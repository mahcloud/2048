defmodule Twenty.Games do
  use GenServer

  def start_link(_args) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])

    Process.register(pid, :games)

    {:ok, pid}
  end

  def get_games(), do: GenServer.call(__MODULE__, :games)
  def get_games(pid), do: GenServer.call(pid, :games)

  def start_game(), do: GenServer.call(__MODULE__, :create)
  def start_game(pid, name), do: GenServer.call(pid, {:create, name})

  ###
  ### Internal
  ###

  def init(state) do
    {:ok, state}
  end

  def handle_call(:games, _from, state), do: {:reply, state, state}
  def handle_call({:create, name}, _from, state) do
    {:ok, pid} = Twenty.Game.start()
    games = state ++ [{pid, name}]
    {:reply, games, games}
  end
end
