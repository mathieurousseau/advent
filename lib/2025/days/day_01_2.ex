defmodule Aoc2025.Day01Two do
  @expected 8
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {_final_pos, zeros} =
      parse(input)
      |> Enum.reduce({50, 0}, fn step, {pos, zeros} ->
        direction = if(step > 0, do: 1, else: -1)

        1..abs(step)
        |> Enum.reduce({pos, zeros}, fn _s, {p, z} ->
          new_pos = rem(p + direction, 100)
          new_zeros = if new_pos == 0, do: z + 1, else: z
          {new_pos, new_zeros}
        end)
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
