defmodule Aoc2023.Day16One do
  @expected 46
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parsed_data = parse_data(input)

    entry_points(input)
    |> Task.async_stream(fn {i, j, direction} ->
      {energized, _visited} = walk(parsed_data, {i, j}, direction, {%{}, %{}})
      map_size(energized)
    end)
    |> Enum.reduce(0, fn {:ok, num}, max -> max(max, num) end)
  end

  defp entry_points(_input) do
    [{0, 0, :right}]
  end

  defp walk(map, point, direction, {_energized, visited} = memo) do
    # IO.puts("#{inspect(point)} - #{direction}")

    if Map.get(visited, {point, direction}) do
      memo
    else
      case {direction, Map.get(map, point)} do
        {_, nil} ->
          memo

        {direction, "."} ->
          continue(direction, point, map, memo)

        {:right, "-"} ->
          continue(direction, point, map, memo)

        {:left, "-"} ->
          continue(direction, point, map, memo)

        {:up, "|"} ->
          continue(direction, point, map, memo)

        {:down, "|"} ->
          continue(direction, point, map, memo)

        {:right, "|"} ->
          split(direction, point, map, memo)

        {:left, "|"} ->
          split(direction, point, map, memo)

        {:up, "-"} ->
          split(direction, point, map, memo)

        {:down, "-"} ->
          split(direction, point, map, memo)

        {:up, "\\"} ->
          memo = energize(memo, point, direction)
          walk(map, next(:left, point), :left, memo)

        {:down, "\\"} ->
          memo = energize(memo, point, direction)
          walk(map, next(:right, point), :right, memo)

        {:right, "\\"} ->
          memo = energize(memo, point, direction)
          walk(map, next(:down, point), :down, memo)

        {:left, "\\"} ->
          memo = energize(memo, point, direction)
          walk(map, next(:up, point), :up, memo)

        {:up, "/"} ->
          memo = energize(memo, point, direction)
          walk(map, next(:right, point), :right, memo)

        {:down, "/"} ->
          memo = energize(memo, point, direction)
          walk(map, next(:left, point), :left, memo)

        {:right, "/"} ->
          memo = energize(memo, point, direction)
          walk(map, next(:up, point), :up, memo)

        {:left, "/"} ->
          memo = energize(memo, point, direction)
          walk(map, next(:down, point), :down, memo)

        wrong ->
          raise("#{wrong}")
      end
    end

    # Map.merge(energleft,
  end

  defp split(direction, point, map, memo) do
    memo = energize(memo, point, direction)

    if direction == :right or direction == :left do
      memo = walk(map, next(:up, point), :up, memo)
      walk(map, next(:down, point), :down, memo)
    else
      memo = walk(map, next(:right, point), :right, memo)
      walk(map, next(:left, point), :left, memo)
    end
  end

  defp continue(direction, point, map, memo) do
    memo = energize(memo, point, direction)
    walk(map, next(direction, point), direction, memo)
  end

  defp energize({energized, visited}, point, direction) do
    {_, energized} = Map.get_and_update(energized, point, &add_one(&1))
    {_, visited} = Map.get_and_update(visited, {point, direction}, &add_one(&1))
    {energized, visited}
  end

  defp next(:right, {i, j}), do: {i, j + 1}
  defp next(:left, {i, j}), do: {i, j - 1}
  defp next(:up, {i, j}), do: {i - 1, j}
  defp next(:down, {i, j}), do: {i + 1, j}

  defp add_one(nil), do: {nil, 1}
  defp add_one(current), do: {current, current + 1}

  defp parse_data(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, i}, map ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {c, j}, map ->
        Map.put(map, {i, j}, c)
      end)
    end)
  end
end
