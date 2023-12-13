defmodule Day12 do
  @expected {"TBD", "TBD"}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
    # Agent.get(:memoization, fn value -> IO.puts("mathieu #{inspect(value)}") end)

    parse_data(input)
    |> Enum.map(&spawn_process_line(&1))
    |> Enum.sum()
  end

  defp spawn_process_line(line) do
    process_line(line)
  end

  defp process_line({springs, checks}) do
    {:ok, pid} = Agent.start_link(fn -> %{} end, name: :memoization)
    springs = String.graphemes(springs)
    last_idx = length(checks) - 1
    # 0..last_idx |> Enum.reduce(&waklk(&1))
    # |> Enum.sum()
    value = walk([], 0, springs, checks, pid) |> dbg
    Agent.stop(pid)
    value
  end

  defp walk(f, l, springs, checks, pid) do
    # case Map.get(memo, {l, springs, checks}) do
    #   nil -> do_walk(f, l, springs, checks, memo)
    #   r -> r
    # end
    map = Agent.get(pid, fn state -> state end)

    case Map.get(map, {l, springs, checks}) do
      nil -> do_walk(f, l, springs, checks, pid) |> put_in_memo(l, springs, checks, pid)
      r -> r
    end
  end

  defp walk(f, l, springs, checks, memo) do
    if length(springs) < length(checks) - 1 + Enum.sum(checks) - l do
      put_in_memo(0, l, springs, checks, memo)
    else
      do_walk(f, 0, springs, checks, memo) |> put_in_memo(l, springs, checks, memo)
    end
  end

  defp do_walk(_f, _, springs, [], _memo) do
    if "#" in springs do
      0
    else
      1
    end
  end

  defp do_walk(_f, l, _, [c | _], _memo) when l > c, do: 0

  defp do_walk(f, l, [], [l], _memo) do
    print(f)
    1
  end

  defp do_walk(f, l, [], [], _memo) do
    print(f)
    1
  end

  defp do_walk(f, l, ["."], [l], _memo) do
    print(f)
    1
  end

  defp put_in_memo(value, l, springs, checks, pid) do
    Agent.update(pid, fn memo ->
      Map.put(memo, {l, springs, checks}, value)
    end)

    # Map.put(memo, {l, springs, checks}, value)
    value
  end

  defp print(springs) do
    # springs |> Enum.reverse() |> Enum.join() |> IO.puts()
  end

  defp do_walk(_f, l, _, [c | _], _memo) when l > c, do: 0
  defp do_walk(_f, l, [], [c | nil], _memo) when l < c, do: 0
  defp do_walk(_f, l, [], [c | _], _memo), do: 0
  defp do_walk(_f, 0, [], [_ | _], _memo), do: 0

  defp do_walk(f, 0 = l, ["." | r_springs] = springs, checks, memo),
    do: walk(["." | f], 0, r_springs, checks, memo) |> put_in_memo(l, springs, checks, memo)

  defp do_walk(_f, l, ["." | _], [c | _], memo) when l < c, do: 0

  defp do_walk(f, l, ["." | r_springs] = springs, [c | r_checks] = checks, memo)
       when l == c,
       do: walk(["." | f], 0, r_springs, r_checks, memo) |> put_in_memo(l, springs, checks, memo)

  defp do_walk(f, l, ["?" | r_springs] = springs, [c | r_checks] = checks, memo)
       when l == c,
       do: walk(["." | f], 0, r_springs, r_checks, memo) |> put_in_memo(l, springs, checks, memo)

  defp do_walk(f, 0 = l, ["?" | r_springs] = springs, checks, memo),
    do:
      (walk(["#" | f], 1, r_springs, checks, memo)
       |> put_in_memo(l, springs, checks, memo)) +
        (walk(["." | f], 0, r_springs, checks, memo)
         |> put_in_memo(l, springs, checks, memo))

  defp do_walk(f, l, ["?" | r_springs] = springs, checks, memo),
    do: walk(["#" | f], l + 1, r_springs, checks, memo) |> put_in_memo(l, springs, checks, memo)

  defp do_walk(f, l, ["#" | r_springs] = springs, checks, memo),
    do: walk(["#" | f], l + 1, r_springs, checks, memo) |> put_in_memo(l, springs, checks, memo)

  defp parse_data(input) do
    input
    |> String.split("\n")
    |> Enum.reduce([], fn line, acc ->
      [springs, checks] = line |> String.split(" ")
      springs = List.duplicate(springs, 5) |> Enum.join("?")
      checks = List.duplicate(checks, 5) |> Enum.join(",")
      # [springs, checks] =
      # [String.duplicate(springs, 5), String.duplicate(checks <> ",", 5)] |> dbg

      checks = String.split(checks, ",", trim: true) |> Enum.map(&String.to_integer(&1))
      # dbg(springs)
      # dbg(checks)
      [{springs, checks} | acc]
    end)
    |> Enum.reverse()
  end

  defp second(_input) do
  end
end
