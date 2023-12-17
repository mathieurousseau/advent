defmodule Day06Two do
  @expected 71503
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    map = parse_data_2(input)

    Enum.map(0..0, &process_race(&1, map))
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

  defp parse_data_2(input) do
    String.split(input, "\n")
    |> Enum.reduce(%{}, fn line, map ->
      [key, value] = String.split(line, ":", trim: true)
      value = String.replace(value, ~r/\s/, "") |> String.to_integer()
      Map.put(map, "#{key}_#{0}", value)
    end)
  end
end
