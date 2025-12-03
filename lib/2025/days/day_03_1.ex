defmodule Aoc2025.Day03One do
  @expected 357
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parse(input)
    |> Enum.map(&highest_line/1)
    |> Enum.sum()
  end

  # find highest line in a single row
  # as a combination of 2 digits, the  second one
  # being after the first one
  defp highest_line(line) do
     [d | [ u | rest]] = line
    {d, u} = rest
    |> Enum.reduce({d, u}, 
      fn next, {d, u} ->
        cond do
          u > d -> {u, next}
          next > u -> {d, next}
          true ->
        {d, u}
        end
      end)
    d * 10 + u 
  end

  # Transforms
  # 123456
  # 654321
  # into
  # [[1,2,3,4,5,6], [6,5,4,3,2,1]]
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
