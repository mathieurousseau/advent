defmodule Advent do
  def run(path) do
    day =
      "lib/days/day_??.ex"
      |> Path.wildcard()
      |> List.last()
      |> tap(&Code.require_file(&1))
      |> String.replace(~r/.*day_(\d\d).ex/, "day\\1")

    day_mod = ("Elixir." <> String.capitalize(day)) |> String.to_atom()

    if File.exists?("#{path}/#{day}_1.txt") do
      input_1 = File.read!("#{path}/#{day}_1.txt")
      input_2 = File.read!("#{path}/#{day}_2.txt")
      day_mod.run(input_1, input_2)
    else
      input = File.read!("#{path}/#{day}.txt")
      day_mod.run(input, input)
    end
  end

  def print do
    run("lib/inputs/") |> IO.inspect()
  end
end
