defmodule Day03 do
  def run(input) do
    {part1(input), part2(input)}
  end

  defp part2(input) do
    lines = String.split(input, "\n")

    groups =
      Enum.chunk_every(lines, 3)
      |> Enum.map(fn group -> Enum.map(group, fn line -> String.codepoints(line) end) end)

    Enum.reduce(groups, 0, fn [r1, r2, r3], acc ->
      diff1 = r1 -- r2
      eq1 = r1 -- diff1
      diff = eq1 -- r3
      eq = eq1 -- diff
      acc + (eq |> hd |> priority)
    end)
  end

  defp part1(input) do
    rucksacks = String.split(input, "\n")
    Enum.reduce(rucksacks, 0, fn rucksack, acc -> acc + per_rucksack(rucksack) end)
  end

  defp per_rucksack(rucksack) do
    {first_h, second_h} = String.split_at(rucksack, div(String.length(rucksack), 2))
    first_h = String.codepoints(first_h)
    second_h = String.codepoints(second_h)
    diff = first_h -- second_h
    equals = first_h -- diff
    MapSet.new(equals) |> Enum.reduce(0, &(priority(&1) + &2))
  end

  defp priority(<<c::utf8>>) do
    if c > 96 do
      # lower
      c - ?a + 1
    else
      # upper
      c - ?A + 1 + 26
    end
  end
end
