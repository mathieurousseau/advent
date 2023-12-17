defmodule Day09Two do
  @expected 2
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parse_data(input) |> Enum.map(&process(&1)) |> Enum.sum()
  end

  defp process(row) do
    if Enum.all?(row, &Kernel.==(&1, 0)) do
      0
    else
      List.last(row) + (next_row(row) |> process())
    end
  end

  defp next_row([a | [b | _] = rest]) do
    [b - a | next_row(rest)]
  end

  defp next_row([_a]) do
    []
  end

  defp parse_data(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, " ", trim: true) |> Enum.map(&String.to_integer(&1)) |> Enum.reverse()
    end)
  end
end
