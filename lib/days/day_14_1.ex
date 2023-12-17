defmodule Day14One do
  @expected 136
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parse_input(input)
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&tilt(&1))
    |> Enum.map(&line_weight(&1))
    |> Enum.sum()
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes(&1))
    |> transpose()

    # |> Enum.map(&String.graphemes(&1))
  end

  defp tilt(line) do
    # IO.puts(line)
    shift([], line, [])
    # IO.puts(line)
  end

  def transpose(lines) do
    lines
    |> Enum.reduce(%{}, fn line, acc ->
      line
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, idx}, acc ->
        {_, acc} =
          Map.get_and_update(acc, idx, fn
            nil -> {nil, [c]}
            current -> {current, [c | current]}
          end)

        acc
      end)
    end)
    |> Enum.map(& &1)
    |> Enum.sort(fn {k, _v}, {k2, _v2} -> k < k2 end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.map(&Enum.reverse(&1))

    # |> Enum.map(&Enum.join(&1))

    # |> Enum.reverse()
  end

  defp shift(rocks, [], new_line), do: new_line ++ rocks

  defp shift(rocks, [tile | rest], new_line) do
    case tile do
      "." ->
        shift(rocks, rest, new_line ++ [tile])

      "#" ->
        shift([], rest, new_line ++ rocks ++ [tile])

      "O" ->
        shift([tile | rocks], rest, new_line)
    end
  end

  defp line_weight(line) do
    line
    |> Enum.with_index()
    |> Enum.reduce(0, fn {c, idx}, acc ->
      if c == "O" do
        acc + 1 + idx
      else
        acc
      end
    end)
  end
end
