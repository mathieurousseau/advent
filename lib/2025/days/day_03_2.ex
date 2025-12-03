defmodule Aoc2025.Day03Two do
  @expected 3_121_910_778_619

  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parse(input)
    |> Enum.map(&highest_line/1)
    |> Enum.sum()
  end

  defp highest_line(line) do
    length = 12

    {sol, _} =
      1..12
      |> Enum.reduce({[], line}, &find_biggest(&1, &2, length))

    sol |> Enum.join("") |> String.to_integer()
  end

  defp find_biggest(_index, {sol, []}, _length), do: {sol, []}

  defp find_biggest(index, {sol, line}, length) do
    line_l = length(line)
    max_index = line_l - 1 - (length - index)

    {digit, digit_index} =
      line
      |> Enum.slice(0..max_index)
      |> Enum.with_index()
      |> Enum.max_by(fn {d, i} -> {d, -i} end)

    {sol ++ [digit], line |> Enum.slice((digit_index + 1)..-1//1)}
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
