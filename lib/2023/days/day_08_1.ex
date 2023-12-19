defmodule Aoc2023.Day08One do
  @expected 6
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {lr, map} = parse_data(input)

    walk(lr, "AAA", lr, map, 0)
  end

  defp walk(_, "ZZZ", _, _, count), do: count

  defp walk(_, nil, _, _, _count), do: raise("nil")

  defp walk(lr, current, [l_or_r], map, count) do
    # Process.sleep(1000)
    [current, " - ", l_or_r] |> Enum.join()
    walk(lr, Map.get(map, {current, l_or_r}), lr, map, count + 1)
  end

  defp walk(lr, current, [next | rest], map, count) do
    # Process.sleep(1000)
    [current, " - ", next] |> Enum.join()
    walk(lr, Map.get(map, {current, next}), rest, map, count + 1)
  end

  defp parse_data(input) do
    lines = String.split(input, "\n", trim: true)
    [lr | map] = lines

    lr =
      lr
      |> String.graphemes()

    # |> Enum.reduce([], fn c, acc ->
    #   if c == "L" do
    #     [0 | acc]
    #   else
    #     [1 | acc]
    #   end
    # end)
    # |> Enum.reverse()

    map =
      Enum.reduce(map, %{}, fn step, acc ->
        [key, targets] = String.split(step, " = ", trim: true)
        [l, r] = String.replace(targets, ~r/\(|\)|\s/, "") |> String.split(",", trim: true)

        Map.put(acc, {key, "L"}, l)
        |> Map.put({key, "R"}, r)
      end)

    {lr, map}
  end
end
