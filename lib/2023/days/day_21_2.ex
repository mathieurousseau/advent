defmodule Aoc2023.Day21Two do
  require Integer
  @expected 250_654_621
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    # raise("kkk")
    {start, {matrix, h, w}} = parse(input)
    # dbg(start)
    # Agent.start_link(fn -> {%{}, MapSet.new()} end, name: :ctx)

    # steps = 6
    # IO.puts("\n\n")
    # IO.inspect(steps)
    # {_, reached} = walk(start, matrix, steps, h, w, {0, 0}, {%{}, MapSet.new()}, 0)
    # # {_, reached} = walk(start, matrix, steps, h, w, {0, 0}, {%{}, MapSet.new()}, rem(steps, 2))
    # {min_x, min_y, max_x, max_y} = min_max_matrix(reached)
    # dbg(MapSet.size(reached))
    # Agent.stop(:ctx)
    # print(matrix, reached, min(0, min_x), min(0, min_y), max(h, max_x), max(w, max_y), h, w)

    IO.puts("\n\n")

    # {_, reached} =
    #   Aoc2023.Day21One.walk(start, matrix, steps, h, w, {0, 0}, {%{}, MapSet.new()}, 0)

    # {min_x, min_y, max_x, max_y} = min_max_matrix(reached)

    # print(
    #   matrix,
    #   reached,
    #   min(0, min_x),
    #   min(0, min_y),
    #   max(h, max_x),
    #   max(w, max_y),
    #   h,
    #   w,
    #   start
    # )
    starting_points = %{
      bottom_right: {{130, 131}, {0, 0}},
      bottom_left: {{130, -1}, {0, 0}},
      top_right: {{-1, 130}, {0, 0}},
      top_left: {{-1, 0}, {0, 0}},
      bottom: {{131, 65}, {-1, 0}},
      top: {{-1, 65}, {1, 0}},
      left: {{65, -1}, {0, 1}},
      right: {{65, 131}, {0, -1}},
      center: {{65, 65}, {0, 0}}
    }

    # exp = 3

    # 1..exp |> Enum.redce([], fn idx, acc ->
    #  if
    # end )
    # steps_3 = 64 + 2 * 131

    # expand_3 = [
    #   [
    #     {:bottom_right, steps_3 - 65 - 66},
    #     {:bottom, steps_3 - 65},
    #     {:bottom_left, steps_3 - 65 - 66}
    #   ],
    #   [{:right, steps_3 - 65}, {:center, 131}, {:left, steps_3 - 65}],
    #   [
    #     {:top_right, steps_3 - 65 - 66},
    #     {:top, steps_3 - 65},
    #     {:top_left, steps_3 - 65 - 66}
    #   ]
    # ]

    steps_5 = 65 + 2 * 131

    expand_5 = [
      [
        {:bottom_right, steps_5 - 131 - 65 - 131},
        {:bottom_right, steps_5 - 65 - 66 - 131},
        {:bottom, steps_5 - 131 - 65},
        {:bottom_left, steps_5 - 65 - 66 - 131},
        {:bottom_left, steps_5 - 131 - 65 - 131}
      ],
      [
        {:bottom_right, steps_5 - 65 - 66 - 131},
        {:bottom_right, steps_5 - 65 - 66},
        {:center, 195 - 64},
        {:bottom_left, steps_5 - 65 - 66},
        {:bottom_left, steps_5 - 65 - 66 - 131}
      ],
      [
        {:right, steps_5 - 65 - 131},
        {:center, 131},
        {:center, 132},
        {:center, 131},
        {:left, steps_5 - 65 - 131}
      ],
      [
        {:top_right, steps_5 - 65 - 131 - 66},
        {:top_right, steps_5 - 65 - 66},
        {:center, 131},
        {:top_left, steps_5 - 65 - 66},
        {:top_left, steps_5 - 65 - 131 - 66}
      ],
      [
        {:top_right, steps_5 - 131 - 65 - 131},
        {:top_right, steps_5 - 65 - 66 - 131},
        {:top, steps_5 - 0 - 131 - 65},
        {:top_left, steps_5 - 65 - 66 - 131},
        {:top_left, steps_5 - 131 - 65 - 131}
      ]
    ]

    # steps = steps_3
    # expand = expand_3
    expand = expand_5

    pattern =
      Enum.map(expand, fn line ->
        Enum.map(line, fn {starting_from, steps} ->
          if steps <= 0 do
            0
          else
            {point, dir} = Map.get(starting_points, starting_from)

            {_, reached} =
              Aoc2023.Day21One.walk(
                point,
                matrix,
                steps,
                h,
                w,
                dir,
                {%{}, MapSet.new()},
                0
              )

            next_frame_size = MapSet.size(reached)
          end
        end)
      end)
      |> dbg
      |> tap(fn t -> t |> List.flatten() |> Enum.sum() |> IO.inspect(label: "sum table") end)
      |> tap(fn t -> t |> Enum.map(&(Enum.sum(&1) |> IO.inspect(label: "line by line"))) end)
      |> IO.inspect()

    first = hd(pattern) |> Enum.sum() |> dbg
    last = List.last(pattern) |> Enum.sum() |> dbg

    [a, b, _, c, d] = Enum.at(pattern, 1)
    inter_first_half = (a + b + c + d) |> dbg

    [a, b, _, c, d] = Enum.at(pattern, 3)
    inter_second_half = (a + b + c + d) |> dbg

    center = pattern |> Enum.at(2) |> Enum.at(2) |> dbg
    next_to_center = pattern |> Enum.at(2) |> Enum.at(3) |> dbg

    [a, _, _, _, b] = Enum.at(pattern, 2)
    middle = (a + b) |> dbg

    steps = 65 + 202_300 * 131
    height = div(steps - 65, 131) * 2 + 1
    mid = round(height / 2)

    1..height
    |> Enum.reduce(0, fn idx, sum ->
      width =
        cond do
          idx < mid ->
            (idx - 1) * 2 + 3

          idx == mid ->
            height

          idx > mid ->
            height - (idx - mid - 1) * 2
        end

      cond do
        idx == 1 ->
          sum + first

        idx == height ->
          sum + last

        idx == mid ->
          repeating = width - 2 - 1

          sum + div(repeating, 2) * 7566 +
            div(repeating, 2) * 7509 +
            center + middle

        idx < mid ->
          repeating = width - 4 - 1

          sum + div(repeating, 2) * 7566 +
            div(repeating, 2) * 7509 +
            center + inter_first_half

        idx > mid ->
          repeating = width - 4 - 1

          sum + div(repeating, 2) * 7566 +
            div(repeating, 2) * 7509 +
            center + inter_second_half
      end
    end)
    |> IO.inspect(label: "result")

    # steps = 65 + 131 * 2

    # raise("5 -> 94315 / 7 -> 184804 / 9 -> 305088")
    # raise("7 -> 184528")

    # total = dbg(MapSet.size(reached))

    # remaining_steps = steps - 65

    # total =
    #   [
    #     {{-1, 65}, {1, 0}, remaining_steps},
    #     {{65, -1}, {0, 1}, remaining_steps},
    #     {{65, 131}, {0, -1}, remaining_steps},
    #     {{131, 65}, {-1, 0}, remaining_steps},
    #     {{-1, 0}, {0, 0}, remaining_steps - 66},
    #     {{-1, 130}, {0, 0}, remaining_steps - 66},
    #     {{130, -1}, {0, 0}, remaining_steps - 66},
    #     {{130, 131}, {0, 0}, remaining_steps - 66}
    #   ]
    #   |> Enum.reduce(total, fn
    #     {_new_start, _dir, step}, total when steps <= 0 ->
    #       total

    #     {new_start, dir, steps} = input, total ->
    #       {_, reached} =
    #         Aoc2023.Day21One.walk(
    #           new_start,
    #           matrix,
    #           steps,
    #           h,
    #           w,
    #           dir,
    #           {%{}, MapSet.new()},
    #           0
    #         )

    #       next_frame_size = MapSet.size(reached)
    #       IO.puts("#{inspect(input)} -> #{next_frame_size}")
    #       next_frame_size + total
    #   end)

    # dbg(total)
    # IO.inspect(steps)
    {_, reached} = walk(start, matrix, steps, h, w, {0, 0}, {%{}, MapSet.new()}, 0)
    # {_, reached} = walk(start, matrix, steps, h, w, {0, 0}, {%{}, MapSet.new()}, 0)
    {min_x, min_y, max_x, max_y} = min_max_matrix(reached)

    # print(
    #   matrix,
    #   reached,
    #   min(0, min_x),
    #   min(0, min_y),
    #   max(h, max_x),
    #   max(w, max_y),
    #   h,
    #   w,
    #   start
    # )

    total_reached = MapSet.size(reached)
    # IO.puts("#{inspect(start)} -> #{total_reached}")
    total_reached
    # end
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

  defp print(matrix, reached, s_x, s_y, e_x, e_y, h, w, start) do
    {:ok, file} = File.open("day21.vis", [:write, :utf8])

    for x <- s_x..e_x, y <- s_y..e_y do
      # IO.inspect({x, y})
      inf_x = rem(h + rem(x, h), h)
      inf_y = rem(w + rem(y, w), w)

      if MapSet.member?(reached, {x, y}) do
        # IO.write("O")
        if({inf_x, inf_y} == start) do
          IO.write(file, "🟪")
        else
          IO.write(file, "🟪")
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

          "." ->
            IO.write(file, "⬜")

          "#" ->
            IO.write(file, "⬛")
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

  @directions [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]

  # defp walk(point, _matrix, steps) do
  #   Agent.get()
  #   Agent.update(:ctx, fn {visited, reached} ->
  #     visited = visit(visited, point, 0)

  #     reached = if Integer.is_odd(steps), do: reached = reach(reached, point), else: reached

  #     {visited, reached}
  #   end)
  # end

  defp walk({x, y} = point, matrix, steps, h, w, {p_x, p_y}, {visited, reached}, rem) do
    # {visited, reached} = Agent.get(:ctx, fn state -> state end)

    # reached = if Integer.is_even(steps), do: reach(reached, point), else: reached
    # reached = if Integer.is_odd(steps), do: reach(reached, point), else: reached
    # rem = rem + (div(x, h) |> rem(2))
    # rem = rem + (div(y, w) |> rem(2))
    # rem = rem(rem, 2)
    # if x == 5, do: IO.puts("#{inspect(point)}, rem: #{rem}")
    # if x >= h or y >= w, do: IO.puts("#{inspect(point)}, rem: #{rem}")
    reached = if rem(steps, 2) == rem, do: reach(reached, point), else: reached

    visited_at_step = Map.get(visited, {point, rem})

    visited =
      if visited_at_step,
        do: visit(visited, point, max(steps, visited_at_step), rem),
        else: visit(visited, point, steps, rem)

    # Agent.update(:ctx, fn _ -> {visited, reached} end)

    # if steps > 0 do
    {visited, reached} =
      if steps > 0 and (is_nil(visited_at_step) or visited_at_step < steps) do
        (@directions -- [{-p_x, -p_y}])
        |> Enum.reduce({visited, reached}, fn {x_off, y_off} = dir, {visited, reached} ->
          {n_x, n_y} = next_coord = {x + x_off, y + y_off}

          inf_x = rem(h + rem(n_x, h), h)
          inf_y = rem(w + rem(n_y, w), w)
          next = Map.get(matrix, {inf_x, inf_y})

          # if is_nil(next) do
          #   IO.inspect(point)
          #   IO.inspect(next_coord)
          #   IO.inspect({rem(n_x, h), rem(n_y, w)})
          # end

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

  defp visit(visited, point, steps, rem), do: Map.put(visited, {point, rem}, steps)

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
