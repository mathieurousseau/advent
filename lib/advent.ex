defmodule Advent do
  def run(path, year, day, part, test \\ true) do
    day_mod = ("Elixir.Aoc#{year}.Day" <> day <> part) |> String.to_atom()
    part_num =
      case part do
        "One" -> 1
        "Two" -> 2
      end

    file_path =
      if test do
        "#{path}/day#{day}_#{part_num}_test.txt"
      else
        "#{path}/day#{day}.txt"
      end

    do_run(file_path, day_mod)
  end

  defp do_run(file_path, day_mod) do
    if File.exists?(file_path) and Code.ensure_loaded?(day_mod) do
      file_path
      |> File.read!()
      |> day_mod.run()
    else
      {:error, "File not found: #{file_path}"}
    end
  end
end
