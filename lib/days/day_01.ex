defmodule Day01 do
  @expected {142, 364}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
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

  defp second(input) do
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
