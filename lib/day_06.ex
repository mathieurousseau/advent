defmodule Day06 do
  @spec run(binary) :: {any, list()}
  def run(input) do
    {part1(input), part2(input)}
  end

  defp part1(input) do
    input
    |> String.split("\n")
    |> Enum.reduce([], fn line, acc ->
      [part1_line(line, 4) | acc]
    end)
    |> Enum.reverse()
  end

  defp part1_line(line, marker_size) do
    marker = :queue.new()

    {_, _, idx} =
      line
      |> String.codepoints()
      |> Enum.reduce_while({marker, %{}, 0}, fn cp, {marker, map, idx} ->
        map = Map.put(map, cp, Map.get(map, cp, 0) + 1)
        marker = :queue.in(cp, marker)

        cond do
          idx < marker_size ->
            {:cont, {marker, map, idx + 1}}

          true ->
            {{:value, old_cp}, marker} = :queue.out(marker)
            map = %{map | old_cp => map[old_cp] - 1}

            if marker?(map, marker_size) do
              {:halt, {marker, map, idx}}
            else
              {:cont, {marker, map, idx + 1}}
            end
        end
      end)

    idx + 1
  end

  defp marker?(map, marker_size) do
    cond do
      map_size(map) < marker_size ->
        false

      true ->
        map
        |> Map.values()
        |> Enum.reduce_while(true, fn count, _is_marker ->
          cond do
            count <= 1 -> {:cont, true}
            true -> {:halt, false}
          end
        end)
    end
  end

  defp part2(input) do
    input
    |> String.split("\n")
    |> Enum.reduce([], fn line, acc ->
      [part1_line(line, 14) | acc]
    end)
    |> Enum.reverse()
  end
end
