defmodule Day14Two do
  @expected 64
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parse_input(input)
    # |> transpose()
    # |> Enum.map(&Enum.reverse(&1))
    # |> print()
    # |> rotate()
    # |> rotate()
    # |> rotate()
    # |> rotate()
    # |> rotate_left()
    # |> print()
    |> cycle(1_000_000_000)
    # |> print()
    # |> print()
    # |> transpose()
    # |> transpose()
    # |> transpose()
    |> transpose()
    |> Enum.map(&Enum.reverse(&1))
    # |> print()
    |> Enum.map(&line_weight(&1))
    |> Enum.sum()
  end

  # defp rotate(data) do
  #   t = transpose(data) |> Enum.map(&Enum.reverse(&1))
  #   print(t)
  #   t
  # end

  defp cycle(data, times, force \\ false) do
    {result, _} =
      1..times
      |> Enum.reduce_while({data, %{}}, fn i, {data, memo} ->
        # IO.puts("#{i}:#{map_size(memo)}")
        key = Enum.map(data, &Enum.join(&1)) |> Enum.join("\n")

        if not force and Map.get(memo, key) do
          from_idx = Map.get(memo, key)
          remaining = rem(times - i, i - from_idx)
          # IO.puts("#{from_idx} -> #{i} : #{remaining}")
          final = cycle(data, remaining + 1, true)
          {:halt, {final, memo}}
        else
          cycled =
            data
            |> transpose()
            |> Enum.map(&Enum.reverse(&1))
            # |> print()
            |> Enum.map(&tilt(&1))
            |> transpose()
            |> Enum.map(&Enum.reverse(&1))
            # |> print()
            |> Enum.map(&tilt(&1))
            |> transpose()
            |> Enum.map(&Enum.reverse(&1))
            # |> print()
            |> Enum.map(&tilt(&1))
            |> transpose()
            |> Enum.map(&Enum.reverse(&1))
            # |> print()
            |> Enum.map(&tilt(&1))

          memo = Map.put(memo, key, i)
          {:cont, {cycled, memo}}
        end
      end)

    result
  end

  # defp print(data) do
  #   data |> Enum.map(&Enum.join(&1)) |> Enum.each(&IO.puts(&1))
  #   IO.puts("\n")
  #   data
  # end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes(&1))

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

  def rotate_left(lines) do
    width = lines |> hd |> length()

    lines
    |> Enum.reduce(%{}, fn line, acc ->
      line
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, idx}, acc ->
        {_, acc} =
          Map.get_and_update(acc, width - 1 - idx, fn
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
