defmodule Advent do
  @days [
    Day01
    # Day02,
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
      input = File.read!("#{path}/#{day}.txt")
      Map.put(acc, day_mod, day_mod.run(input))
    end)
  end

  def print do
    run("lib/inputs/") |> IO.inspect()
  end
end
