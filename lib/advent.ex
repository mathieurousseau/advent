defmodule Advent do
  @current_day "16"
  def run(path) do
    day_mod = ("Elixir.Day" <> @current_day) |> String.to_atom()

    if File.exists?("#{path}/day_#{@current_day}_1.txt") do
      input_1 = File.read!("#{path}/day#{@current_day}_1.txt")
      input_2 = File.read!("#{path}/day#{@current_day}_2.txt")
      day_mod.run(input_1, input_2)
    else
      input = File.read!("#{path}/day#{@current_day}.txt")
      day_mod.run(input, input)
    end
  end

  def print do
    IO.puts(DateTime.utc_now())
    run("lib/inputs/") |> IO.inspect()
    IO.puts(DateTime.utc_now())

    IO.puts("\n\n---- TEST DATA ----\n\n")
  end
end
