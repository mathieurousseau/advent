defmodule Day13 do
  @expected {405, "TBD"}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
    input
    |> String.replace("#", "1")
    |> String.replace(".", "0")
    |> String.split("\n\n", trim: true)
    |> Enum.chunk_every(2)
    # |> dbg
    |> Enum.map(fn [h_pattern, v_pattern] ->
      [process_patterns(h_pattern), process_patterns(v_pattern)] |> Enum.sum()
    end)
    |> Enum.sum()
  end

  defp process_patterns(pattern) do
    {direction, {idx, {r, c}}} =
      find_line(pattern)
      |> case do
        {nil, nil} ->
          {idx, {c, r}} = find_line(pattern, true)
          {:vertical, {idx, {r, c}}}

        {idx, {r, c}} = smudge ->
          {:horizontal, {idx * 100, {r, c}}}
      end

    idx
    # IO.puts(pattern)

    # corrected =
    #   pattern
    #   |> String.split("\n")
    #   |> Enum.with_index()
    #   |> Enum.map(fn {l, idx} ->
    #     # IO.puts("#{r}//#{c}")

    #     if idx == r do
    #       char =
    #         case String.at(l, c) do
    #           "1" -> "0"
    #           "0" -> "1"
    #         end

    #       l |> String.graphemes() |> List.replace_at(c, char) |> Enum.join()
    #       # {p1, p2} = String.split_at(l, idx)
    #       # p1 <> c <> p2
    #     else
    #       l
    #     end
    #   end)
    #   |> Enum.join("\n")

    # IO.puts(corrected)

    # case direction do
    # :horizontal -> Day13PartOne.find_line_mirror(corrected) * 100
    # :vertical -> Day13PartOne.find_line_mirror(corrected, true)
    # end

    # case Day13PartOne.find_line_mirror(corrected) do
    #   0 -> Day13PartOne.find_line_mirror(corrected, true)
    #   value -> 100 * value
    # end

    # d = Day13PartOne.find_line_mirror(corrected, true)

    # if smu
    # d = find_line(pattern, true)
    # c * 100
    # c * 100 + d
    # {c * 100, d}
  end

  defp find_line(pattern, transpose \\ false) do
    lines = String.split(pattern, "\n", trim: true)
    # l = length(lines)

    lines =
      if transpose do
        Day11.transpose(lines)
      else
        lines
      end

    find_smudge(lines, [], [], 0)
  end

  defp find_smudge([first | [second | r]], [], [], idx),
    do: find_smudge(r, [first], [second], idx + 1)

  defp find_smudge(lines, top, bottom, idx) do
    # IO.inspect(lines)
    # IO.inspect(top)
    # IO.inspect(Enum.reverse(bottom))
    # IO.puts("#{idx}\n")

    b_top = Enum.join(top) |> String.to_integer(2)
    b_bottom = bottom |> Enum.reverse() |> Enum.join() |> String.to_integer(2)

    compare =
      Bitwise.bxor(b_top, b_bottom)
      |> Integer.to_string(2)

    if String.replace(compare, "0", "") == "1" do
      [_, part_2] = String.split(compare, "1")
      line_length = top |> hd() |> String.length()
      total_length = Enum.join(top) |> String.length()
      r = idx - length(top) + div(total_length - String.length(part_2), line_length)
      c = rem(total_length - String.length(part_2) - 1, line_length)
      # IO.puts("idx: #{idx} ; row: #{r} ; col: #{c} ; #{compare}")
      {idx, {r, c}}
    else
      do_find_smudge(lines, top, bottom, idx)
    end
  end

  defp do_find_smudge(_, [], [_ | _], _), do: raise("Really")

  # defp do_find_smudge(_, top, bottom, idx) when top == bottom, do: idx

  # defp do_find_smudge([], [top], [bottom], idx) when top != bottom, do: 0
  defp do_find_smudge([], [top], [bottom], idx), do: {nil, nil}

  defp do_find_smudge([first | [second | rest]], top, [f_bottom | rest_bottom], idx),
    do: find_smudge(rest, top ++ [f_bottom], rest_bottom ++ [first, second], idx + 1)

  defp do_find_smudge([first], [_ | [_ | _] = top], [f_bottom | [_ | _] = rest_bottom], idx),
    do: find_smudge([], top ++ [f_bottom], rest_bottom ++ [first], idx + 1)

  defp do_find_smudge([], [_ | [_ | [_ | _] = top]], [f_bottom | [_ | _] = rest_bottom], idx),
    do: find_smudge([], top ++ [f_bottom], rest_bottom, idx + 1)

  defp do_find_smudge([], [_, _], [f_bottom | [_ | _] = rest_bottom], idx),
    do: find_smudge([], [f_bottom], rest_bottom, idx + 1)

  defp(second(_input)) do
  end
end
