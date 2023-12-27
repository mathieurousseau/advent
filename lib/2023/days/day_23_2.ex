defmodule Aoc2023.Day23Two do
  @expected 154
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {matrix, h, w} = parse(input)
    result = walk({0, 1}, matrix, MapSet.new(), {h - 1, w - 2}, 0) - 1
    IO.inspect(result)
  end

  defp walk({h, w} = _point, _matrix, _visited, {h, w}, _), do: 1

  defp walk(point, matrix, visited, the_end, parallel) do
    with false <- MapSet.member?(visited, point),
         visited <- MapSet.put(visited, point),
         current <- Map.get(matrix, point),
         [_ | _] = nexts <- next(current, point, matrix, visited),
         nexts_size <- length(nexts),
         concurrency <- if(parallel >= 2, do: 1, else: min(nexts_size, 2)),
         #  paths <- Enum.map(nexts, &walk(&1, matrix, visited, the_end)),
         paths_stream <-
           Task.async_stream(nexts, &walk(&1, matrix, visited, the_end, parallel),
             timeout: :infinity,
             max_concurrency: concurrency
           ),
         paths <- Enum.to_list(paths_stream) |> Enum.map(fn {:ok, count} -> count end),
         [_ | _] = possible_paths <- Enum.reject(paths, &is_nil(&1)) do
      Enum.max(possible_paths) + 1
    else
      _ -> nil
    end
  end

  @dir [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
  # defp next(">", {x, y}, _matrix, _visited), do: [{x, y + 1}]
  # defp next("<", {x, y}, _matrix, _visited), do: [{x, y - 1}]
  # defp next("v", {x, y}, _matrix, _visited), do: [{x + 1, y}]
  # defp next("^", {x, y}, _matrix, _visited), do: [{x - 1, y}]
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
