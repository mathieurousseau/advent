defmodule Aoc2025.Day02Two do
  @expected 4_174_379_265
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parse(input)

    # [95..115]
    |> Enum.reduce(0, fn range, acc ->
      Enum.reduce(range, acc, fn n, acc ->
        # check is length of n is even
        if repeated(Integer.to_string(n)) do
          acc + n
        else
          acc
        end
      end)
    end)
  end

  defp repeated(str) do
    len = String.length(str)

    1..len
    |> Enum.any?(fn size ->
      chunks =
        String.graphemes(str) |> Enum.chunk_every(size)

      length(chunks) > 1 and
        MapSet.new(chunks) |> MapSet.size() == 1
    end)
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
