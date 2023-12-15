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
    |> Task.async_stream(&process_line(&1))
    |> Enum.reduce(0, fn {:ok, num}, acc -> num + acc end)
  end

  defp process_line({springs, checks}) do
    # {:ok, pid} = Agent.start_link(fn -> %{} end, name: :memoization)
    springs = String.graphemes(springs)
    # 0..last_idx |> Enum.reduce(&waklk(&1))
    # |> Enum.sum()
    {result, memo} = walk([], 0, springs, checks, %{})
    # Agent.stop(pid)
    result
  end

  defp walk(f, l, springs, checks, memo) do
    # case Map.get(memo, {l, springs, checks}) do
    #   nil -> do_walk(f, l, springs, checks, memo)
    #   r -> r
    # end
    # map = Agent.get(pid, fn state -> state end)

    case Map.get(memo, {l, springs, checks}) do
      nil ->
        do_walk(f, l, springs, checks, memo)
        |> put_in_memo(l, springs, checks)

      r ->
        {r, memo}
    end
  end

  defp walk(f, l, springs, checks, memo) do
    if length(springs) < length(checks) - 1 + Enum.sum(checks) - l do
      {0, put_in_memo({0, memo}, l, springs, checks)}
    else
      {res, memo} = do_walk(f, 0, springs, checks, memo)
      put_in_memo(l, springs, checks, memo)
    end
  end

  defp do_walk(_f, _, springs, [], memo) do
    if "#" in springs do
      {0, memo}
    else
      {1, memo}
    end
  end

  defp do_walk(_f, l, _, [c | _], memo) when l > c, do: {0, memo}

  defp do_walk(f, l, [], [l], memo) do
    print(f)
    {1, memo}
  end

  defp do_walk(f, l, [], [], memo) do
    print(f)
    {1, memo}
  end

  defp do_walk(f, l, ["."], [l], memo) do
    print(f)
    {1, memo}
  end

  defp put_in_memo({value, memo}, l, springs, checks) do
    memo = Map.put(memo, {l, springs, checks}, value)
    {value, memo}
  end

  defp print(springs) do
    # springs |> Enum.reverse() |> Enum.join() |> IO.puts()
  end

  defp do_walk(_f, l, _, [c | _], memo) when l > c, do: {0, memo}
  defp do_walk(_f, l, [], [c | nil], memo) when l < c, do: {0, memo}
  defp do_walk(_f, l, [], [c | _], memo), do: {0, memo}
  defp do_walk(_f, 0, [], [_ | _], memo), do: {0, memo}

  defp do_walk(f, 0 = l, ["." | r_springs] = springs, checks, memo),
    do: walk(["." | f], 0, r_springs, checks, memo) |> put_in_memo(l, springs, checks)

  defp do_walk(_f, l, ["." | _], [c | _], memo) when l < c, do: {0, memo}

  defp do_walk(f, l, ["." | r_springs] = springs, [c | r_checks] = checks, memo)
       when l == c,
       do: walk(["." | f], 0, r_springs, r_checks, memo) |> put_in_memo(l, springs, checks)

  defp do_walk(f, l, ["?" | r_springs] = springs, [c | r_checks] = checks, memo)
       when l == c,
       do: walk(["." | f], 0, r_springs, r_checks, memo) |> put_in_memo(l, springs, checks)

  defp do_walk(f, 0 = l, ["?" | r_springs] = springs, checks, memo) do
    {res, memo} = walk(["#" | f], 1, r_springs, checks, memo)

    {res2, memo} = walk(["." | f], 0, r_springs, checks, memo)
    put_in_memo({res + res2, memo}, l, springs, checks)
  end

  defp do_walk(f, l, ["?" | r_springs] = springs, checks, memo),
    do: walk(["#" | f], l + 1, r_springs, checks, memo) |> put_in_memo(l, springs, checks)

  defp do_walk(f, l, ["#" | r_springs] = springs, checks, memo),
    do: walk(["#" | f], l + 1, r_springs, checks, memo) |> put_in_memo(l, springs, checks)

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
