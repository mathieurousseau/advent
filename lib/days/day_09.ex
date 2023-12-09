defmodule Day09 do
  @expected {2, "TBD"}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
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

  defp second(_input) do
  end
end
