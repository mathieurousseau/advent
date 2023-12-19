defmodule Aoc2023.Day10One do
  @expected 8
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    # start = {22, 92}
    map = parse(input)
    start = Map.get(map, "start")

    {map, from} =
      case start do
        {2, 0} ->
          {Map.put(map, start, "F"), "bottom"}

        {22, 91} ->
          {Map.put(map, start, "J"), "left"}

        _ ->
          raise("not a good start: #{inspect(start)}")
      end

    Map.get(map, start)
    (walk(start, from, start, MapSet.new(), map, 0) - 1) / 2
  end

  defp walk(start, _from, start, _visited, _map, steps) when steps > 0, do: steps + 1

  defp walk(start, from, current, visited, map, steps) do
    {next_from, to} = next(from, current, map)

    # IO.inspect(Map.get(map, current))
    # IO.inspect("#{from}/#{inspect(current)} -> #{next_from}/#{inspect(to)}")

    walk(start, next_from, to, visited, map, steps + 1)
  end

  # @spec(from, current) :: next
  defp next(from, current, map) do
    case {from, Map.get(map, current)} do
      {"bottom", "|"} -> {"bottom", up(current)}
      {"bottom", "7"} -> {"right", left(current)}
      {"bottom", "F"} -> {"left", right(current)}
      {"top", "|"} -> {"top", down(current)}
      {"top", "L"} -> {"left", right(current)}
      {"top", "J"} -> {"right", left(current)}
      {"left", "J"} -> {"bottom", up(current)}
      {"left", "7"} -> {"top", down(current)}
      {"left", "-"} -> {"left", right(current)}
      {"right", "L"} -> {"bottom", up(current)}
      {"right", "F"} -> {"top", down(current)}
      {"right", "-"} -> {"right", left(current)}
      _ -> raise("not possible: #{from}, #{inspect(current)}, #{Map.get(map, current)}")
    end
  end

  defp right({c_r, c_c}), do: {c_r, c_c + 1}
  defp left({c_r, c_c}), do: {c_r, c_c - 1}
  defp up({c_r, c_c}), do: {c_r - 1, c_c}
  defp down({c_r, c_c}), do: {c_r + 1, c_c}

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, row}, map ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {c, col}, map ->
        if c == "S" do
          Map.put(map, "start", {row, col})
        else
          map
        end
        |> Map.put({row, col}, c)
      end)
    end)
  end
end
