defmodule Day13PartOne do
  @expected {405, "TBD"}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
    String.split(input, "\n\n", trim: true)
    |> Enum.chunk_every(2)
    # |> dbg
    |> Enum.map(fn [pattern_1, pattern_2] ->
      [process_patterns(pattern_1), process_patterns(pattern_2)] |> Enum.sum()
    end)
    |> Enum.sum()
  end

  defp process_patterns(pattern) do
    c = find_line_mirror(pattern)
    d = find_line_mirror(pattern, true)
    c * 100 + d
    # {min(c, d), max(c, d)}
  end

  def find_line_mirror(pattern, transpose \\ false) do
    lines = String.split(pattern, "\n", trim: true)
    # l = length(lines)

    if transpose do
      Day11.transpose(lines)
    else
      lines
    end
    |> walk([], [], 0)
  end

  defp walk([first | [second | r]], [], [], idx), do: walk(r, [first], [second], idx + 1)

  defp walk(lines, top, bottom, idx) do
    # IO.inspect(lines)
    # IO.inspect(top)
    # IO.inspect(Enum.reverse(bottom))
    # IO.puts("#{idx}\n")

    if top == Enum.reverse(bottom) do
      idx
    else
      do_walk(lines, top, bottom, idx)
    end
  end

  defp do_walk(_, [], [_ | _], _), do: raise("Really")

  defp do_walk(_, top, bottom, idx) when top == bottom, do: idx

  defp do_walk([], [top], [bottom], idx) when top != bottom, do: 0

  defp do_walk([first | [second | rest]], top, [f_bottom | rest_bottom], idx),
    do: walk(rest, top ++ [f_bottom], rest_bottom ++ [first, second], idx + 1)

  defp do_walk([first], [_ | [_ | _] = top], [f_bottom | [_ | _] = rest_bottom], idx),
    do: walk([], top ++ [f_bottom], rest_bottom ++ [first], idx + 1)

  defp do_walk([], [_ | [_ | [_ | _] = top]], [f_bottom | [_ | _] = rest_bottom], idx),
    do: walk([], top ++ [f_bottom], rest_bottom, idx + 1)

  defp do_walk([], [_, _], [f_bottom | [_ | _] = rest_bottom], idx),
    do: walk([], [f_bottom], rest_bottom, idx + 1)

  defp(second(_input)) do
  end
end
