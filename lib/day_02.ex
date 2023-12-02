defmodule Day02 do
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {output_1, output_2}
  end

  @available_cubes %{"red" => 12, "green" => 13, "blue" => 14}
  defp first(input) do
    String.split(input, "\n")
    |> Enum.reduce(0, fn line, acc ->
      process_game(line) + acc
    end)
  end

  defp process_game(line) do
    ["Game " <> id, hands] = String.split(line, ":")

    if hands |> String.split(";", trim: true) |> Enum.all?(&valid_hands(&1)) do
      String.to_integer(id)
    else
      0
    end
  end

  defp valid_hands(hand) do
    hand
    |> String.split(",", trim: true)
    |> Enum.all?(fn cubes ->
      [number, color] = String.split(cubes, " ", trim: true)
      @available_cubes[color] >= String.to_integer(number)
    end)
  end

  defp second(input) do
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
