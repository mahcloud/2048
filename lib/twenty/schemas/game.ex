defmodule Twenty.Schemas.GameSchema do
  defstruct [:name]
  @types %{name: :string}

  import Ecto.Changeset

  def changeset(%Twenty.Schemas.GameSchema{} = game, attrs) do
    {game, @types}
    |> cast(attrs, Map.keys(@types))
    |> update_change(:name, &String.trim/1)
    # TODO: handle nil on String.trim
    |> validate_not_empty([:name])
    |> validate_unique_name()
  end

  ###
  ### PRIVATE
  ###

  defp is_field_valid(changeset, field) do
    cond do
      get_field(changeset, field) == nil ->
        changeset |> add_error(field, "is required")
      String.trim(get_field(changeset, field)) == "" ->
        changeset |> add_error(field, "is required")
      true -> changeset
    end
  end

  defp validate_not_empty(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, changeset ->
      changeset |> is_field_valid(field)
    end)
  end

  defp validate_unique_name(changeset) do
    name = changeset
    |> Ecto.Changeset.get_field(:name)

    pid = Process.whereis(:games)
    Twenty.Games.get_games(pid)
    |> Enum.map(fn {_pid, game_name} -> game_name end)
    |> Enum.member?(name)
    |> case do
      false -> changeset
      _ -> changeset |> add_error(:name, "is already taken")
    end
  end
end
