defmodule Twenty.Game do
  use GenServer

  @initial_state [
    [nil, nil, nil, nil],
    [nil, nil, nil, nil],
    [nil, nil, nil, nil],
    [nil, nil, nil, nil],
  ]

  def start() do
    start_link([])
  end

  def combine(direction) do
    GenServer.call(__MODULE__, {:combine, direction})
  end
  def combine(pid, direction) do
    GenServer.call(pid, {:combine, direction})
  end

  def end_game(pid, reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(pid, reason, timeout)
  end

  def get_board(), do: GenServer.call(__MODULE__, :board)
  def get_board(pid), do: GenServer.call(pid, :board)

  def increment(), do: GenServer.call(__MODULE__, :increment)
  def increment(pid), do: GenServer.call(pid, :increment)

  ###
  ### Internal
  ###

  def init(state) do
    {:ok, state}
  end

  def handle_call(:board, _, state), do: {:reply, state, state}
  def handle_call({:combine, direction}, _, state) do
    Twenty.Board.combine(%{board: state, direction: direction})
    |> case do
      {:ok, board} -> {:reply, {:ok, board}, board}
      {:error, board, error} -> {:reply, {:error, error}, board}
    end
  end
  def handle_call(:increment, _, state) do
    Twenty.Board.increment(state)
    |> case do
      {:ok, board} -> {:reply, {:ok, board}, board}
      {:error, board, error} -> {:reply, {:error, error}, board}
    end
  end

  def start_link(_opts) do
    state = 4..10
    |> Enum.reduce(@initial_state, fn _n, acc ->
      acc |> Twenty.Board.increment()
    end)

    GenServer.start_link(__MODULE__, state)
  end
end