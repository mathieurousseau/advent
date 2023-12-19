defmodule Aoc2023.Day11One do
  @expected 374
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    lines = String.split(input, "\n")

    # IO.puts("-----")

    # IO.inspect(lines == lines)
    # IO.inspect(lines == transpose(lines))
    # IO.inspect(lines == transpose(transpose(lines)))

    # IO.puts("-----")

    expand(lines)
    # |> tap(&Enum.each(&1, fn l -> IO.puts(l) end))
    |> transpose()
    |> transpose()
    # |> tap(&Enum.each(&1, fn l -> IO.puts(l) end))
    |> transpose()
    # |> tap(&Enum.each(&1, fn l -> IO.puts(l) end))
    |> expand()
    |> transpose()
    |> Enum.reverse()
    # |> tap(&Enum.each(&1, fn l -> IO.puts(l) end))
    # |> tap(&IO.inspect("#{length(&1)}"))
    # |> tap(&IO.inspect("#{&1 |> hd() |> String.length()}"))
    |> extract_galaxies()
    |> calc_distances()
    |> elem(1)

    # |> Enum.sum()
    # |> div(2)
  end

  defp calc_distances(galaxies) do
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
                abs(s_r - f_r) + abs(s_c - f_c)
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

  defp expand(lines) do
    # height = length(lines)
    width = lines |> hd |> String.length()

    lines
    |> Enum.reduce([], fn line, acc ->
      empty = String.duplicate(".", width)

      if line == empty do
        [empty | [line | acc]]
      else
        [line | acc]
      end
    end)
    |> Enum.reverse()
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
    |> Enum.sort(fn {k, _v}, {k2, _v2} -> k < k2 end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&Enum.join(&1))

    # |> Enum.reverse()
  end
end
