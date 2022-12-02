defmodule Day02 do
  # A: Rock :X 1
  # B: Pape :Y 2
  # C: Scis :Z 3
  @scores_first %{
    "A X" => 3 + 1,
    "A Y" => 6 + 2,
    "A Z" => 0 + 3,
    "B X" => 0 + 1,
    "B Y" => 3 + 2,
    "B Z" => 6 + 3,
    "C X" => 6 + 1,
    "C Y" => 0 + 2,
    "C Z" => 3 + 3
  }
  def run(input) do
    battles = String.split(input, "\n")

    {first(battles), second(battles)}
  end

  defp first(battles) do
    Enum.reduce(battles, 0, fn battle, sum -> sum + Map.get(@scores_first, battle) end)
  end

  @scores_second %{
    "A X" => "A Z",
    "A Y" => "A X",
    "A Z" => "A Y",
    "B X" => "B X",
    "B Y" => "B Y",
    "B Z" => "B Z",
    "C X" => "C Y",
    "C Y" => "C Z",
    "C Z" => "C X"
  }
  defp second(battles) do
    Enum.reduce(battles, 0, fn battle, sum ->
      expected_score = Map.get(@scores_second, battle)
      sum + Map.get(@scores_first, expected_score)
    end)
  end
end
