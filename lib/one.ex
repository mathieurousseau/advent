defmodule One do
  def run do
    input = File.read!("lib/inputs/one.txt")
    chunks = String.split(input, "\n\n")
    calories = Enum.map(chunks, fn chunk -> sum_chunk(chunk) end) |> Enum.sort(:desc)
    top_3 = Enum.take(calories, 3)
    highest = Enum.take(top_3, 1) |> hd
    top_three = calories |> Enum.take(3) |> Enum.sum()
    {highest, top_three}
  end

  def sum_chunk(chunk) do
    chunk |> String.split("\n") |> Enum.reduce(0, fn cal, acc -> acc + String.to_integer(cal) end)
  end
end
