defmodule Aoc2023.Day23One do
  @expected 94
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {matrix, h, w} = parse(input)
    walk({0, 1}, matrix, MapSet.new(), {h - 1, w - 2}) - 1
  end

  defp walk({h, w} = _point, _matrix, _visited, {h, w}), do: 1

  defp walk(point, matrix, visited, the_end) do
    with false <- MapSet.member?(visited, point),
         visited <- MapSet.put(visited, point),
         current <- Map.get(matrix, point),
         next <- next(current, point, matrix, visited),
         paths <- Enum.map(next, &walk(&1, matrix, visited, the_end)),
         [_ | _] = possible_paths <- Enum.reject(paths, &is_nil(&1)) do
      Enum.max(possible_paths) + 1
    else
      _ -> nil
    end
  end

  @dir [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
  defp next(">", {x, y}, _matrix, _visited), do: [{x, y + 1}]
  defp next("<", {x, y}, _matrix, _visited), do: [{x, y - 1}]
  defp next("v", {x, y}, _matrix, _visited), do: [{x + 1, y}]
  defp next("^", {x, y}, _matrix, _visited), do: [{x - 1, y}]
  defp next("#", _, _, _), do: raise("no no")

  defp next(_, {x, y} = _point, matrix, visited) do
    Enum.map(@dir, fn {dir_x, dir_y} ->
      next_point_coord = {x + dir_x, y + dir_y}
      next_point = Map.get(matrix, next_point_coord)

      if not is_nil(next_point) and next_point != "#" and
           not MapSet.member?(visited, next_point_coord) do
        next_point_coord
      end
    end)
    |> Enum.reject(&is_nil(&1))
  end

  defp parse(input) do
    {matrix, h, w} = Aoc.to_matrix_map(input)
  end
end
