defmodule Aoc do
  def to_matrix(input, func \\ nil) do
    matrix =
      input
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, i}, map ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(map, fn {c, j}, map ->
          c =
            if func do
              func.(c)
            else
              c
            end

          Map.put(map, {i, j}, c)
        end)
      end)

    h = String.split(input, "\n") |> length()
    w = String.split(input, "\n") |> hd() |> String.length()
    {matrix, h, w}
  end
end
