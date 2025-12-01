defmodule Aoc2025.Day01One do
  @expected 3
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {_final_pos, zeros} =
      parse(input)
      |> Enum.reduce({50, 0}, fn step, {pos, zeros} ->
        # module 99 to wrap around the circle
        new_pos = rem(pos + step, 100)
        zeros = if new_pos == 0, do: zeros + 1, else: zeros
        {new_pos, zeros}
      end)

    zeros
  end

  defp parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn line ->
      case String.at(line, 0) do
        "L" -> ("-" <> String.slice(line, 1..-1//1)) |> String.to_integer()
        "R" -> String.slice(line, 1..-1//1) |> String.to_integer()
      end
    end)
  end
end
