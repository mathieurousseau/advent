defmodule Day04 do
  def run(input) do
    {part1(input), part2(input)}
  end

  defp part1(input) do
    pairs = String.split(input, "\n")
    Enum.reduce(pairs, 0, fn pair, acc -> (pair |> extract |> full_overlap) + acc end)
  end

  defp full_overlap({s1, e1, s2, e2}) do
    if (s1 <= s2 and e1 >= e2) or (s2 <= s1 and e2 >= e1) do
      1
    else
      0
    end
  end

  defp extract(pair) do
    [e1, e2] = String.split(pair, ",")
    [s1, e1] = String.split(e1, "-") |> Enum.map(&String.to_integer(&1))
    [s2, e2] = String.split(e2, "-") |> Enum.map(&String.to_integer(&1))
    {s1, e1, s2, e2}
  end

  defp part2(input) do
    pairs = String.split(input, "\n")
    Enum.reduce(pairs, 0, fn pair, acc -> acc + (pair |> extract |> any_overlap) end)
  end

  defp any_overlap({s1, e1, s2, e2}) do
    cond do
      s1 <= s2 and e1 >= s2 -> 1
      s2 <= s1 and e2 >= s1 -> 1
      true -> 0
    end
  end
end
