defmodule Advent do
  @days [
    Day01,
    Day02,
    Day03
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
