defmodule Twenty.Game do
  use GenServer

  @initial_state [
    [1, 1, 1, 1 ],
    [1, 1, 1, 1 ],
    [1, 1, 1, 1 ],
    [1, 1, 1, 1 ],
  ]

  def start() do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def end_game(pid, reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(pid, reason, timeout)
  end

  def get_board() do
    GenServer.call(__MODULE__, :board)
  end

  def combine(location, direction) do
    GenServer.call(__MODULE__, {:combine, location, direction})
  end

  ###
  # Internal
  ###

  def init(state) do
    {:ok, state}
  end

  def handle_call(:board, _, state) do
    {:reply, state, state}
  end

  def handle_call({:combine, location, direction}, _, state) do
    Twenty.Board.combine(%{board: state, direction: direction, location: location})
    |> case do
      {:ok, board} -> {:reply, {:ok, board}, board}
      {:error, board, error} -> {:reply, {:error, error}, board}
    end
  end
end

defmodule Twenty.Board do
  def combine(%{board: board, direction: direction, location: {x, y}}) do
    {:ok, %{board: board, direction: direction, x: x, y: y}}
    |> calculate_value()
    |> calculate_direction()
    |> validate_value()
    |> validate_x()
    |> validate_y()
    |> run_combine()
    |> extract_board()
  end

  ###
  ### PRIVATE
  ###

  defp calculate_direction({:ok, %{direction: :down, x: x} = data}), do: {:ok, data |> Map.put(:x, x + 1)}
  defp calculate_direction({:ok, %{direction: :left, y: y} = data}), do: {:ok, data |> Map.put(:y, y - 1)}
  defp calculate_direction({:ok, %{direction: :right, y: y} = data}), do: {:ok, data |> Map.put(:y, y + 1)}
  defp calculate_direction({:ok, %{direction: :up, x: x} = data}), do: {:ok, data |> Map.put(:x, x - 1)}
  defp calculate_direction({:error, data}), do: {:error, data}

  defp calculate_value({:ok, %{board: board, x: x, y: y} = data}) do
    value = board
    |> Enum.at(y)
    |> Enum.at(x)
    {:ok, data |> Map.put(:value, value)}
  end
  defp calculate_value({:error, data}), do: {:error, data}

  defp extract_board({:ok, %{board: board}}), do: {:ok, board}
  defp extract_board({:error, %{board: board, error: error}}), do: {:error, board, error}

  defp run_combine({:ok, %{board: board, value: value, x: x, y: y} = data}) do
    row = board
    |> Enum.at(y)
    |> List.replace_at(x, value + value)

    new_board = board
    |> List.replace_at(y, row)

    {:ok, data |> Map.put(:board, new_board)}
  end
  defp run_combine({:error, data}), do: {:error, data}

  defp validate_value({:ok, %{board: board, value: original_value, x: x, y: y} = data}) do
    value = board
    |> Enum.at(y)
    |> Enum.at(x)

    if value === original_value do
      {:ok, data}
    else
      {:error, data |> Map.put(:error, "Values do not match #{original_value} and #{value}")}
    end
  end
  defp validate_value({:error, data}), do: {:error, data}

  defp validate_x({:ok, %{x: 0} = data}), do: {:ok, data}
  defp validate_x({:ok, %{x: 1} = data}), do: {:ok, data}
  defp validate_x({:ok, %{x: 2} = data}), do: {:ok, data}
  defp validate_x({:ok, %{x: 3} = data}), do: {:ok, data}
  defp validate_x({:ok, data}), do: {:error, data |> Map.put(:error, "Location is invalid. X is invalid")}
  defp validate_x({:error, data}), do: {:error, data}

  defp validate_y({:ok, %{y: 0} = data}), do: {:ok, data}
  defp validate_y({:ok, %{y: 1} = data}), do: {:ok, data}
  defp validate_y({:ok, %{y: 2} = data}), do: {:ok, data}
  defp validate_y({:ok, %{y: 3} = data}), do: {:ok, data}
  defp validate_y({:ok, data}), do: {:error, data |> Map.put(:error, "Location is invalid. Y is invalid")}
  defp validate_y({:error, data}), do: {:error, data}
end