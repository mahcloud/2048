defmodule Twenty.Board do
  # new row
  def combine(%{x: 4, y: y} = params), do: combine(params |> Map.put(:x, 0) |> Map.put(:y, y + 1))
  # last row
  def combine(%{board: board, y: 4}), do: {:ok, board}
  def combine(%{direction: :left, x: 0} = params), do: combine(params |> Map.put(:x, 1))
  def combine(%{direction: :right, x: 3} = params), do: combine(params |> Map.put(:x, 4))
  def combine(%{direction: :down, x: x, y: 3} = params), do: combine(params |> Map.put(:x, x + 1))
  def combine(%{direction: :up, x: x, y: 0} = params), do: combine(params |> Map.put(:x, x + 1))
  def combine(%{direction: direction, board: board, original_board: original_board, x: x, y: y} = params) do
    original_value = get_value(original_board, x, y)
    value = get_value(board, x, y)
    {next_value, next_x, next_y} = get_next_value(board, x, y, direction)

    cond do
      original_value != value -> combine(params |> Map.put(:x, x + 1))
      value != nil && value == next_value -> combine_values(params, {x, y, value}, {next_x, next_y, next_value})
      next_value == nil && value != nil -> combine_values(params, {x, y, value}, {next_x, next_y, next_value})
      true -> combine(params |> Map.put(:x, x + 1))
    end
  end
  def combine(%{board: board} = params), do: combine(params |> Map.put(:x, 0) |> Map.put(:y, 0) |> Map.put(:original_board, board))

  def increment(board) do
    nils = board
    |> find_nil_indexes()

    cond do
      length(nils) == 0 -> board
      true ->
        {x, y} = nils
        |> Enum.random()

        board
        |> replace_value(x, y, 1)
    end
  end

  ###
  ### PRIVATE
  ###

  defp combine_values(%{board: board} = params, {x, y, value}, {next_x, next_y, next_value}) do
    new_value = next_value
    |> case do
      nil -> value
      _ -> value + next_value
    end

    board = board
    |> replace_value(next_x, next_y, new_value)
    |> replace_value(x, y, nil)

    params = params
    |> Map.put(:board, board)
    |> Map.put(:x, x + 1)

    combine(params)
  end

  defp find_nil_indexes(board) do
    board
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, index}, acc ->
      acc |> Enum.concat(row |> find_nil_indexes_in_row(index))
    end)
  end

  defp find_nil_indexes_in_row(row, y) do
    row
    |> Enum.with_index()
    |> Enum.filter(fn {tile, _index} -> tile == nil end)
    |> Enum.map(fn {_tile, x} -> {x, y} end)
  end

  defp get_next_value(board, x, y, :down) do
    y = y + 1
    {get_value(board, x, y), x, y}
  end
  defp get_next_value(board, x, y, :left) do
    x = x - 1
    {get_value(board, x, y), x, y}
  end
  defp get_next_value(board, x, y, :right) do
    x = x + 1
    {get_value(board, x, y), x, y}
  end
  defp get_next_value(board, x, y, :up) do
    y = y - 1
    {get_value(board, x, y), x, y}
  end

  defp get_value(board, x, y) do 
    board
    |> Enum.at(y)
    |> Enum.at(x)
  end

  defp replace_value(board, x, y, value) do
    row = board
    |> Enum.at(y)
    |> List.replace_at(x, value)

    board
    |> List.replace_at(y, row)
  end
end
