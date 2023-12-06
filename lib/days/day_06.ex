defmodule Day06 do
  @expected {288, 71503}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
    map = parse_data(input)
    length = div(map_size(map), 2)

    Enum.map(0..(length - 1), &process_race(&1, map))
    |> Enum.product()
  end

  defp process_race(idx, map) do
    t = "Time_#{idx}"
    d = "Distance_#{idx}"

    Enum.reduce(0..map[t], 0, fn pressed, sum ->
      distance = (map[t] - pressed) * pressed
      if distance > map[d], do: sum + 1, else: sum
    end)
  end

  defp parse_data(input) do
    String.split(input, "\n")
    |> Enum.reduce(%{}, fn line, map ->
      [key, values] = String.split(line, ":", trim: true)

      values
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer(&1))
      |> Enum.with_index()
      |> Enum.reduce(map, fn {num, index}, map ->
        Map.put(map, "#{key}_#{index}", num)
      end)
    end)
  end

  defp second(input) do
    map = parse_data_2(input)

    Enum.map(0..0, &process_race(&1, map))
    |> Enum.product()
  end

  defp parse_data_2(input) do
    String.split(input, "\n")
    |> Enum.reduce(%{}, fn line, map ->
      [key, value] = String.split(line, ":", trim: true)
      value = String.replace(value, ~r/\s/, "") |> String.to_integer()
      Map.put(map, "#{key}_#{0}", value)
    end)
  end
end
