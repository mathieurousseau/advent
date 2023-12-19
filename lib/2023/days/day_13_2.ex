defmodule Aoc2023.Day13Two do
  @expected 400
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
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
    {_direction, {idx, {_r, _c}}} =
      find_line(pattern)
      |> case do
        {nil, nil} ->
          {idx, {c, r}} = find_line(pattern, true)
          {:vertical, {idx, {r, c}}}

        {idx, {r, c}} ->
          {:horizontal, {idx * 100, {r, c}}}
      end

    idx
  end

  defp find_line(pattern, transpose \\ false) do
    lines = String.split(pattern, "\n", trim: true)
    # l = length(lines)

    lines =
      if transpose do
        Aoc2023.Day11Two.transpose(lines)
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
  defp do_find_smudge([], [_top], [_bottom], _idx), do: {nil, nil}

  defp do_find_smudge([first | [second | rest]], top, [f_bottom | rest_bottom], idx),
    do: find_smudge(rest, top ++ [f_bottom], rest_bottom ++ [first, second], idx + 1)

  defp do_find_smudge([first], [_ | [_ | _] = top], [f_bottom | [_ | _] = rest_bottom], idx),
    do: find_smudge([], top ++ [f_bottom], rest_bottom ++ [first], idx + 1)

  defp do_find_smudge([], [_ | [_ | [_ | _] = top]], [f_bottom | [_ | _] = rest_bottom], idx),
    do: find_smudge([], top ++ [f_bottom], rest_bottom, idx + 1)

  defp do_find_smudge([], [_, _], [f_bottom | [_ | _] = rest_bottom], idx),
    do: find_smudge([], [f_bottom], rest_bottom, idx + 1)
end
