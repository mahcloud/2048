defmodule Twenty.Game do
  use GenServer

  @initial_state [
    [1, 1, 1, 1 ],
    [1, 1, 1, 1 ],
    [1, 1, 1, 1 ],
    [1, 1, 1, 1 ],
  ]

  def start() do
    start_link([])
  end

  def end_game(pid, reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(pid, reason, timeout)
  end

  def get_board(), do: GenServer.call(__MODULE__, :board)
  def get_board(pid), do: GenServer.call(pid, :board)

  def combine(location, direction) do
    GenServer.call(__MODULE__, {:combine, location, direction})
  end
  def combine(pid, location, direction) do
    GenServer.call(pid, {:combine, location, direction})
  end

  ###
  ### Internal
  ###

  def init(state) do
    {:ok, state}
  end

  def handle_call(:board, _, state), do: {:reply, state, state}
  def handle_call({:combine, location, direction}, _, state) do
    Twenty.Board.combine(%{board: state, direction: direction, location: location})
    |> case do
      {:ok, board} -> {:reply, {:ok, board}, board}
      {:error, board, error} -> {:reply, {:error, error}, board}
    end
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, @initial_state)
  end
end