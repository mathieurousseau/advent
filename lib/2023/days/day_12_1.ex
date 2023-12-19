defmodule Aoc2023.Day12One do
  @expected 21
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parse_data(input) |> Enum.map(&process_line(&1)) |> Enum.sum()
  end

  defp process_line({springs, checks}) do
    springs = String.graphemes(springs)
    walk([], 0, springs, checks)
  end

  # defpwalk(f, l, springs, checks) do
  #   if length(springs) < length(checks) - 1 + Enum.sum(checks) - l do
  #     0
  #   else
  #     do_walk(0, springs, checks)
  #   end
  # end
  defp walk(f, l, springs, checks), do: do_walk(f, l, springs, checks)

  defp do_walk(_f, _, springs, []) do
    if "#" in springs do
      0
    else
      1
    end
  end

  defp do_walk(_f, l, _, [c | _]) when l > c, do: 0

  defp do_walk(_f, l, [], [l]), do: 1

  defp do_walk(_f, _l, [], []), do: 1

  defp do_walk(_f, l, ["."], [l]), do: 1

  defp do_walk(_f, l, _, [c | _]) when l > c, do: 0
  defp do_walk(_f, l, [], [c | nil]) when l < c, do: 0
  defp do_walk(_f, _l, [], [_c | _]), do: 0
  defp do_walk(_f, 0, [], [_ | _]), do: 0
  defp do_walk(f, 0, ["." | r_springs], checks), do: walk(["." | f], 0, r_springs, checks)

  defp do_walk(_f, l, ["." | _], [c | _]) when l < c, do: 0

  defp do_walk(f, l, ["." | r_springs], [c | r_checks]) when l == c,
    do: walk(["." | f], 0, r_springs, r_checks)

  defp do_walk(f, l, ["?" | r_springs], [c | r_checks]) when l == c,
    do: walk(["." | f], 0, r_springs, r_checks)

  defp do_walk(f, 0, ["?" | r_springs], checks),
    do: walk(["#" | f], 1, r_springs, checks) + walk(["." | f], 0, r_springs, checks)

  defp do_walk(f, l, ["?" | r_springs], checks),
    do: walk(["#" | f], l + 1, r_springs, checks)

  defp do_walk(f, l, ["#" | r_springs], checks), do: walk(["#" | f], l + 1, r_springs, checks)

  defp parse_data(input) do
    input
    |> String.split("\n")
    |> Enum.reduce([], fn line, acc ->
      [springs, checks] = line |> String.split(" ")
      checks = String.split(checks, ",") |> Enum.map(&String.to_integer(&1))
      [{springs, checks} | acc]
    end)
    |> Enum.reverse()
  end
end
