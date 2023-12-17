defmodule Day15One do
  @expected 1320
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    input |> String.split(",") |> Enum.map(&transform(&1)) |> Enum.sum()
  end

  defp transform(line) do
    line
    |> String.to_charlist()
    |> Enum.reduce(0, fn c, acc ->
      c |> Kernel.+(acc) |> Kernel.*(17) |> rem(256)
    end)
  end
end
