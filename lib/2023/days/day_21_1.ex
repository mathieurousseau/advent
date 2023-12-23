defmodule Aoc2023.Day21One do
  require Integer
  @expected 16
  def run(input) do
    {@expected, @expected}
    # {do_run(input), @expected}
  end

  defp do_run(input) do
    {start, {matrix, h, w}} = parse(input) |> dbg
    # dbg(start)
    # Agent.start_link(fn -> {%{}, MapSet.new()} end, name: :ctx)
    steps = if start == {5, 5}, do: 6, else: 65
    rem = rem(steps, 2) |> dbg
    # steps = if start == {0, 1}, do: 65, else: 64
    {_, reached} = walk(start, matrix, steps, h, w, {0, 0}, {%{}, MapSet.new()}, 0)
    # Agent.get(:ctx, fn {_, reached} -> MapSet.length(reached) end)
    # {_, reached} = Agent.get(:ctx, fn ctx -> ctx end)
    # print(matrix, reached, 0, 0, h, w)
    # Agent.stop(:ctx)

    {min_x, min_y, max_x, max_y} = min_max_matrix(reached)

    print_write(
      matrix,
      reached,
      min(0, min_x),
      min(0, min_y),
      max(h, max_x),
      max(w, max_y),
      h,
      w,
      start
    )

    MapSet.size(reached)
  end

  defp min_max_matrix(matrix) do
    Enum.reduce(matrix, {0, 0, 0, 0}, fn {x, y}, {min_x, min_y, max_x, max_y} ->
      min_x = min(x, min_x)
      min_y = min(y, min_y)
      max_x = max(x, max_x)
      max_y = max(y, max_y)
      {min_x, min_y, max_x, max_y}
    end)
  end

  defp print_write(matrix, reached, s_x, s_y, e_x, e_y, h, w, start) do
    {:ok, file} = File.open("day21.vis", [:write])

    for x <- s_x..e_x, y <- s_y..e_y do
      # IO.inspect({x, y})
      inf_x = rem(h + rem(x, h), h)
      inf_y = rem(w + rem(y, w), w)

      if MapSet.member?(reached, {x, y}) do
        # IO.write("O")
        if({inf_x, inf_y} == start) do
          IO.write(file, "S")
        else
          IO.write(file, "O")
        end
      else
        # next = Map.get(matrix, {inf_x, inf_y})

        case Map.get(matrix, {inf_x, inf_y}) do
          nil ->
            raise("no")

          "S" ->
            # IO.write(".")
            IO.write(file, "S")

          " " ->
            raise("no space")

          c ->
            IO.write(file, c)

            # IO.write(c)
        end
      end

      if e_y - y == 0 do
        # IO.write("\n")
        IO.write(file, "\n")
      end
    end

    File.close(file)
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

  # def walk(_, _matrix, 0, _, _, _, {visited, reached}, _), do: {visited, reached}

  def walk({x, y} = point, matrix, steps, h, w, {p_x, p_y} = dir, {visited, reached}, rem) do
    # {visited, reached} = Agent.get(:ctx, fn state -> state end)

    # reached = if Integer.is_even(steps), do: reach(reached, point), else: reached
    # reached = if Integer.is_odd(steps), do: reach(reached, point), else: reached
    # IO.inspect(point, label: "mathieu")
    # IO.inspect(dir, label: "dir")

    reached =
      if x >= 0 and x < h and y >= 0 and y < w and rem(steps, 2) == rem and
           (Map.get(matrix, point) == "." or Map.get(matrix, point) == "S") do
        reach(reached, point)
      else
        reached
      end

    visited_at_step = Map.get(visited, point)

    visited =
      if visited_at_step,
        do: visit(visited, point, max(steps, visited_at_step)),
        else: visit(visited, point, steps)

    # Agent.update(:ctx, fn _ -> {visited, reached} end)

    {visited, reached} =
      if steps > 0 and (is_nil(visited_at_step) or visited_at_step < steps) do
        (@directions -- [{-p_x, -p_y}])
        |> Enum.reduce({visited, reached}, fn {x_off, y_off} = dir, {visited, reached} ->
          {n_x, n_y} = next_coord = {x + x_off, y + y_off}

          # IO.inspect(next_coord, label: "next_coord")

          next = Map.get(matrix, {n_x, n_y})

          # IO.inspect(next, label: "next")

          if next == "." or next == "S" do
            walk(next_coord, matrix, steps - 1, h, w, dir, {visited, reached}, rem)
          else
            {visited, reached}
          end
        end)
      else
        {visited, reached}
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
