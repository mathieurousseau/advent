defmodule Aoc2023.Day02One do
  @expected 8
  def run(input) do
    {do_run(input), @expected}
  end

  @available_cubes %{"red" => 12, "green" => 13, "blue" => 14}

  defp do_run(input) do
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
end
