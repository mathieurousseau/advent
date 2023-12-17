defmodule Day04One do
  @expected 13
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    String.split(input, "\n")
    |> Enum.map(&calculate_line(&1))
    |> Enum.reduce(0, fn line_results, acc -> acc + line_results end)
  end

  defp calculate_line(line) do
    [_, winning, chosen] =
      Regex.scan(~r/Card\s+\d+:(.*) \| (.*)/, line)
      |> List.flatten()

    winning_set = String.split(winning, " ", trim: true) |> MapSet.new()

    chosen_set = String.split(chosen, " ", trim: true) |> MapSet.new()

    right_numbers_size = MapSet.intersection(winning_set, chosen_set) |> MapSet.size()

    case right_numbers_size do
      0 -> 0
      _ -> :math.pow(2, right_numbers_size - 1)
    end
  end
end
