defmodule Aoc2025.Day02One do
  @expected 1_227_775_554
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parse(input)
    |> Enum.reduce(0, fn range, acc ->
      Enum.reduce(range, acc, fn n, acc ->
        # check is length of n is even
        if Integer.digits(n) |> length() |> rem(2) == 0 do
          if symetrical(Integer.to_string(n)) do
            acc + n
          else
            acc
          end
        else
          acc
        end
      end)
    end)
  end

  defp symetrical(str) do
    len = String.length(str)
    half = div(len, 2)
    first_half = String.slice(str, 0, half) |> String.to_integer()
    second_half = String.slice(str, half, half) |> String.to_integer()

    first_half == second_half
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> hd()
    |> String.split(",")
    |> Enum.map(&parse_range/1)
  end

  defp parse_range(range) do
    [start, stop] = String.split(range, "-")
    String.to_integer(start)..String.to_integer(stop)
  end
end
