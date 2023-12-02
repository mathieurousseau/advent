defmodule Advent do
  @days [
    Day01,
    Day02
    # Day03,
    # Day04,
    # Day05,
    # Day06,
    # Day07,
    # Day08
  ]

  def run(path) do
    @days
    |> Enum.reduce(%{}, fn day_mod, acc ->
      day = day_mod |> to_string |> String.replace(~r/Elixir\./, "") |> Macro.underscore()

      if File.exists?("#{path}/#{day}_1.txt") do
        input_1 = File.read!("#{path}/#{day}_1.txt")
        input_2 = File.read!("#{path}/#{day}_2.txt")
        Map.put(acc, day_mod, day_mod.run(input_1, input_2))
      else
        input = File.read!("#{path}/#{day}.txt")
        Map.put(acc, day_mod, day_mod.run(input, input))
      end
    end)
  end

  def print do
    run("lib/inputs/") |> IO.inspect()
  end
end
