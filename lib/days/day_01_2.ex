defmodule Day01Two do
  @expected 281
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    input
    |> String.split("\n")
    |> Enum.reduce(0, fn line, acc ->
      extract_first_last(line) + acc
    end)
  end

  @map %{
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9
  }
  @keys ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
  @regex_match Enum.join(@keys, "|")
  @reversed_regex String.reverse(@regex_match)
  defp extract_first_last(line) do
    first =
      Regex.replace(~r/(#{@regex_match})/, line, fn _, x -> "#{Map.get(@map, x)}" end,
        global: true
      )
      |> then(fn converted ->
        Regex.replace(~r/[[:alpha:]]/, converted, "", global: true)
        |> String.at(0)
        |> String.to_integer()
      end)

    second =
      Regex.replace(
        ~r/(#{@reversed_regex})/,
        String.reverse(line),
        fn _, x -> "#{Map.get(@map, String.reverse(x))}" end,
        global: true
      )
      |> then(fn converted ->
        Regex.replace(~r/[[:alpha:]]/, converted, "", global: true)
        |> String.at(0)
        |> String.to_integer()
      end)

    first * 10 + second
  end
end
