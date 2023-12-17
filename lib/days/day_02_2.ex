defmodule Day02Two do
  @expected 2286
  def run(input) do
    {do_run(input), @expected}
  end

  @available_cubes %{"red" => 12, "green" => 13, "blue" => 14}

  defp do_run(input) do
    lines = String.split(input, "\n", trim: true)

    games_hands =
      Enum.map(lines, fn line ->
        ["Game " <> _id, hands] = String.split(line, ":", trim: true)
        String.replace(hands, ";", ",")
      end)

    games_hands
    |> Enum.map(fn game_hand ->
      cubes = String.split(game_hand, ",", trim: true)
      cubes = Enum.map(cubes, fn cube -> String.split(cube, " ", trim: true) end)

      Enum.reduce(cubes, %{"red" => 0, "green" => 0, "blue" => 0}, fn [number, color], minimums ->
        Map.update(minimums, color, 0, fn existing_value ->
          String.to_integer(number) |> max(existing_value)
        end)
      end)
    end)
    |> Enum.reduce(0, fn %{"red" => red, "green" => green, "blue" => blue}, sum ->
      max(red, 1) * max(blue, 1) * max(green, 1) + sum
    end)
  end
end
