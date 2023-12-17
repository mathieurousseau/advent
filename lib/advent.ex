defmodule Advent do
  def run(path, day, part) do
    day_mod = ("Elixir.Day" <> day <> part) |> String.to_atom()

    if File.exists?("#{path}/day#{day}_1.txt") do
      input_1 = File.read!("#{path}/day#{day}_1.txt")
      input_2 = File.read!("#{path}/day#{day}_2.txt")

      case part do
        "One" -> day_mod.run(input_1)
        "Two" -> day_mod.run(input_2)
      end
    else
      input = File.read!("#{path}/day#{day}.txt")
      day_mod.run(input)
    end
  end
end
