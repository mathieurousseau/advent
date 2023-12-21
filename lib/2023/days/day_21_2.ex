defmodule Aoc2023.Day21Two do
  require Integer
  @expected 16
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {start, {matrix, h, w}} = parse(input)
    dbg(start)
    Agent.start_link(fn -> {%{}, MapSet.new()} end, name: :ctx)
    steps = if start == {5, 5}, do: 10, else: 64
    walk(start, matrix, steps)
    # Agent.get(:ctx, fn {_, reached} -> MapSet.length(reached) end)
    {_, reached} = Agent.get(:ctx, fn ctx -> ctx end)
    print(matrix, reached, 0, 0, h, w)
    MapSet.size(reached)
  end

  defp print(matrix, reached, s_x, s_y, h, w) do
    for x <- s_x..h, y <- s_y..w, w do
      # IO.inspect({x, y})

      if MapSet.member?(reached, {x, y}) do
        IO.write("O")
      else
        IO.write(Map.get(matrix, {x, y}))
      end

      if y == w - 1, do: IO.write("\n")
    end
  end

  @directions [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]

  # defp walk(point, _matrix, steps) do
  #   Agent.get()
  #   Agent.update(:ctx, fn {visited, reached} ->
  #     visited = visit(visited, point, 0)

  #     reached = if Integer.is_odd(steps), do: reached = reach(reached, point), else: reached

  #     {visited, reached}
  #   end)
  # end

  defp walk({x, y} = point, matrix, steps) do
    {visited, reached} = Agent.get(:ctx, fn state -> state end)

    reached = if Integer.is_even(steps), do: reach(reached, point), else: reached

    visited_at_step = Map.get(visited, point)

    visited =
      if visited_at_step,
        do: visit(visited, point, max(steps, visited_at_step)),
        else: visit(visited, point, steps)

    Agent.update(:ctx, fn _ -> {visited, reached} end)

    if steps > 0 and (is_nil(visited_at_step) or visited_at_step < steps) do
      @directions
      |> Enum.each(fn {x_off, y_off} ->
        next_coord = {x + x_off, y + y_off}
        next = Map.get(matrix, next_coord)
        if next == "." or next == "S", do: walk(next_coord, matrix, steps - 1)
      end)
    end
  end

  defp visit(visited, point, steps), do: Map.put(visited, point, steps)

  defp reach(reached, point), do: MapSet.put(reached, point)

  defp parse(input) do
    matrix_with_size = Aoc.to_matrix_map(input)

    start =
      input
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.reduce_while(0, fn {line, x}, _ ->
        case Regex.run(~r/S/, line, return: :index) do
          [{y, 1}] ->
            {:halt, {x, y}}

          _ ->
            {:cont, 0}
        end
      end)

    {start, matrix_with_size}
  end
end
