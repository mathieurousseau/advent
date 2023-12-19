defmodule Aoc2023.Day01One do
  @expected 142
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    input
    |> String.split("\n")
    |> Enum.reduce(0, fn line, acc ->
      extract_fist_and_last_digits(line) + acc
    end)
  end

  defp extract_fist_and_last_digits(line) do
    digits = Regex.replace(~r/[[:alpha:]]/, line, "", global: true)
    digits_length = String.length(digits)

    cond do
      digits_length == 0 ->
        0

      digits_length == 1 ->
        String.to_integer(digits <> digits)

      true ->
        (String.at(digits, 0) <> String.at(digits, digits_length - 1)) |> String.to_integer()
    end
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
end
