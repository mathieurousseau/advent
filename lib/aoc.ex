defmodule Aoc do
  def to_matrix_map(input, func \\ nil) do
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

  def transpose_matrix(lines) do
    lines
    |> Enum.reduce(%{}, fn line, acc ->
      line
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, idx}, acc ->
        {_, acc} =
          Map.get_and_update(acc, idx, fn
            nil -> {nil, [c]}
            current -> {current, [c | current]}
          end)

        acc
      end)
    end)
    |> Enum.map(& &1)
    |> Enum.sort(fn {k, _v}, {k2, _v2} -> k < k2 end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.map(&Enum.reverse(&1))
  end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b) when is_number(a) and is_number(b), do: div(a * b, gcd(a, b))

  def lcm([a, b]) do
    lcm(a, b)
  end

  def lcm([a | b]) do
    lcm(a, lcm(b))
  end
end
