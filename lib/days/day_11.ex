defmodule Day11 do
  @expected {"TBD", "TBD"}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
    lines = String.split(input, "\n")
    # lines |> transpose() |> Enum.each(&IO.puts(&1))

    # IO.puts("#{length(extract_galaxies(lines))}")
    # Enum.each(lines, fn l -> IO.puts(l) end)
    # IO.puts("-----")

    # IO.inspect(lines == )
    # IO.inspect(lines == transpose(lines))
    # IO.inspect(lines == transpose(transpose(lines)))

    # Enum.each(transpose(lines), fn l -> IO.puts(l) end)
    # IO.puts("-----")
    # Enum.each(transpose(transpose(lines)), fn l -> IO.puts(l) end)

    horizontal_indexes = expand_indexes(lines)
    vertical_indexes = lines |> transpose() |> expand_indexes()
    # |> tap(&Enum.each(&1, fn l -> IO.puts(l) end))
    # |> tap(&Enum.each(&1, fn l -> IO.puts(l) end))
    # |> tap(&Enum.each(&1, fn l -> IO.puts(l) end))
    # |> tap(&Enum.each(&1, fn l -> IO.puts(l) end))
    # |> tap(&IO.inspect("#{length(&1)}"))
    # |> tap(&IO.inspect("#{&1 |> hd() |> String.length()}"))
    lines
    |> extract_galaxies()
    # |> tap(&IO.inspect("#{length(&1)}"))
    |> calc_distances(horizontal_indexes, vertical_indexes)
    |> elem(1)

    # |> Enum.sum()
    # |> div(2)
  end

  defp calc_distances(galaxies, h_idx, v_idx) do
    for {f_r, f_c} = first <- galaxies,
        {s_r, s_c} = second <- galaxies,
        reduce: {MapSet.new(), 0} do
      {visited, sum} ->
        if MapSet.member?(visited, {first, second}) do
          {visited, sum}
        else
          distance =
            cond do
              first == second ->
                0

              true ->
                h_gaps = MapSet.intersection(h_idx, MapSet.new(f_r..s_r)) |> MapSet.size()
                v_gaps = MapSet.intersection(v_idx, MapSet.new(f_c..s_c)) |> MapSet.size()
                mult = 1_000_000

                abs(s_r - f_r) + (h_gaps * mult - h_gaps) + abs(s_c - f_c) +
                  (v_gaps * mult - v_gaps)
            end

          # if f_r == 37 do
          #   IO.inspect("#{inspect(first)} ->#{inspect(second)}: #{distance}")
          # end

          # distance
          {visited |> MapSet.put({first, second}) |> MapSet.put({second, first}), sum + distance}
        end
    end
  end

  defp extract_galaxies(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, r}, galaxies ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(galaxies, fn {char, c}, galaxies ->
        case char do
          "." -> galaxies
          "#" -> [{r, c} | galaxies]
        end
      end)
    end)
  end

  defp expand_indexes(lines) do
    # height = length(lines)
    width = lines |> hd |> String.length()

    lines
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, idx}, acc ->
      empty = String.duplicate(".", width)

      if line == empty do
        MapSet.put(acc, idx)
      else
        acc
      end
    end)
  end

  defp transpose(lines) do
    lines
    |> Enum.reduce(%{}, fn line, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, idx}, acc ->
        {_, acc} =
          Map.get_and_update(acc, idx, fn
            nil -> {nil, [c]}
            current -> {current, [c | current]}
          end)

        acc
      end)
    end)
    |> Enum.map(& &1)
    |> Enum.sort(fn {k, v}, {k2, v2} -> k < k2 end)
    |> Enum.map(fn {k, v} -> v end)
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&Enum.join(&1))

    # |> Enum.reverse()
  end

  defp second(_input) do
  end
end
