defmodule Day10 do
  @expected {"TBD", "TBD"}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
    # start = {22, 92}
    map = parse(input)
    start = Map.get(map, "start")

    {map, from} =
      case start do
        {2, 0} ->
          {Map.put(map, start, "F"), "bottom"}

        {22, 91} ->
          {Map.put(map, start, "J"), "left"}

        {1, 1} ->
          {Map.put(map, start, "F"), "bottom"}

        {4, 12} ->
          {Map.put(map, start, "F"), "bottom"}

        {0, 4} ->
          {Map.put(map, start, "7"), "bottom"}

        _ ->
          raise("not a good start: #{inspect(start)}")
      end

    Map.get(map, start) |> dbg

    map = walk(start, from, start, MapSet.new(), map, 0)
    [from_left, from_up] = find_direction(map) |> dbg
    Map.get(map, start) |> dbg
    # dbg()
    h_tiles = find_tiles_from_left(map, from_left)
    v_tiles = find_tiles_from_top(map, from_up)
    MapSet.intersection(h_tiles, v_tiles) |> MapSet.size()
  end

  # defp find_outbound(%{r_l: r_l, c_l: c_l} = map) do
  #   0..r_l
  #   |> Enum.reduce(0, fn r, count ->
  #     0..c_l
  #     |> Enum.reduce(count, fn c, count ->

  #     end)
  #   end)
  # end
  # defp print(%{r_l: r_l, c_l: c_l} = map) do
  #   0..r_l
  #   |> Enum.reduce({0, 0, []}, fn r, acc ->
  #     0..c_l
  #     |> Enum.reduce(acc, fn c, {count, inside, inside_togglers} ->

  #     end)
  #   end)
  # end

  defp find_tiles_from_left(%{r_l: r_l, c_l: c_l} = map, inside_toggler) do
    IO.inspect(inside_toggler)

    0..r_l
    |> Enum.reduce(MapSet.new(), fn r, tiles ->
      {tiles, _} =
        0..c_l
        |> Enum.reduce({tiles, 0}, fn c, {tiles, inside} ->
          case Map.get(map, {r, c}) do
            [_ | _] = direction ->
              # IO.puts("#{r},#{c} - #{inspect(direction)}")

              inside =
                if inside_toggler in direction do
                  1
                else
                  0
                end

              {tiles, inside}

            direction ->
              # IO.puts("#{r},#{c} - #{inspect(direction)} - #{inside}")

              if inside == 1 do
                {MapSet.put(tiles, {r, c}), inside}
              else
                {tiles, inside}
              end
          end
        end)

      tiles
    end)
  end

  defp find_tiles_from_top(%{r_l: r_l, c_l: c_l} = map, inside_toggler) do
    IO.inspect(inside_toggler)

    0..c_l
    |> Enum.reduce(MapSet.new(), fn c, tiles ->
      {tiles, _} =
        0..r_l
        |> Enum.reduce({tiles, 0}, fn r, {tiles, inside} ->
          case Map.get(map, {r, c}) do
            [_ | _] = direction ->
              # IO.puts("#{r},#{c} - #{inspect(direction)}")

              inside =
                if inside_toggler in direction do
                  1
                else
                  0
                end

              {tiles, inside}

            direction ->
              # IO.puts("#{r},#{c} - #{inspect(direction)} - #{inside}")

              if inside == 1 do
                {MapSet.put(tiles, {r, c}), inside}
              else
                {tiles, inside}
              end
          end
        end)

      tiles
    end)
  end

  defp find_direction(%{r_l: r_l, c_l: c_l} = map) do
    {_, _, togglers} =
      0..r_l
      |> Enum.reduce({0, 0, []}, fn r, acc ->
        {count, _, inside_togglers} = acc

        0..c_l
        |> Enum.reduce({count, 0, inside_togglers}, fn c, {count, inside, inside_togglers} ->
          case Map.get(map, {r, c}) do
            [_ | _] = direction ->
              inside_togglers =
                if [] == inside_togglers do
                  if :u in direction or :r in direction do
                    [:u, :r]
                  else
                    [:d, :l]
                  end
                  |> dbg
                else
                  inside_togglers
                end

              inside =
                (direction -- inside_togglers !=
                   [])
                |> if do
                  0
                else
                  1
                end

              {count, inside, inside_togglers}

            _ ->
              {count + inside, inside, inside_togglers}
          end
        end)
      end)

    togglers
  end

  defp walk(start, _from, start, _visited, map, steps) when steps > 0, do: map

  defp walk(start, from, current, visited, map, steps) do
    {next_from, to, direction} = next(from, current, map)
    map = Map.put(map, current, direction)

    # IO.inspect(Map.get(map, current))
    # IO.inspect("#{from}/#{inspect(current)} -> #{next_from}/#{inspect(to)}")

    walk(start, next_from, to, visited, map, steps + 1)
  end

  # @spec(from, current) :: next
  defp next(from, current, map) do
    case {from, Map.get(map, current)} do
      {"bottom", "|"} -> {"bottom", up(current), [:u]}
      {"bottom", "7"} -> {"right", left(current), [:u, :l]}
      {"bottom", "F"} -> {"left", right(current), [:u, :r]}
      {"top", "|"} -> {"top", down(current), [:d]}
      {"top", "L"} -> {"left", right(current), [:d, :r]}
      {"top", "J"} -> {"right", left(current), [:d, :l]}
      {"left", "J"} -> {"bottom", up(current), [:r, :u]}
      {"left", "7"} -> {"top", down(current), [:r, :d]}
      {"left", "-"} -> {"left", right(current), [:r]}
      {"right", "L"} -> {"bottom", up(current), [:l, :u]}
      {"right", "F"} -> {"top", down(current), [:l, :d]}
      {"right", "-"} -> {"right", left(current), [:l]}
      _ -> raise("not possible: #{from}, #{inspect(current)}, #{Map.get(map, current)}")
    end
  end

  defp right({c_r, c_c}), do: {c_r, c_c + 1}
  defp left({c_r, c_c}), do: {c_r, c_c - 1}
  defp up({c_r, c_c}), do: {c_r - 1, c_c}
  defp down({c_r, c_c}), do: {c_r + 1, c_c}

  defp parse(input) do
    lines =
      input
      |> String.split("\n")

    r_l = length(lines)
    c_l = lines |> hd |> String.length()
    map = %{count: 0, r_l: r_l, c_l: c_l}

    lines
    |> Enum.with_index()
    |> Enum.reduce(map, fn {line, row}, map ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {c, col}, map ->
        case c do
          "S" ->
            Map.put(map, "start", {row, col})

          "." ->
            {_, map} =
              Map.get_and_update!(map, :count, fn current ->
                {current, current + 1}
              end)

            map

          _ ->
            map
        end
        |> Map.put({row, col}, c)
      end)
    end)
  end

  defp second(_input) do
  end
end