defmodule Day05 do
  @spec run(binary) :: {1, 2}
  def run(input) do
    {part1(input), part2(input)}
  end

  defp part1(input) do
    lines = String.split(input, "\n")

    %{data: data, moves: moves} =
      Enum.reduce(lines, %{data: [], moves: []}, fn line, acc ->
        cond do
          line == "" -> acc
          String.starts_with?(line, "move") -> %{acc | moves: [line | acc[:moves]]}
          line =~ "[" -> %{acc | data: [line | acc[:data]]}
          true -> acc
        end
      end)

    col_num = lines |> hd |> String.length() |> Kernel.+(1) |> div(4)
    cols = 0..(col_num - 1) |> Enum.reduce(%{}, fn idx, acc -> Map.put(acc, idx, []) end)

    Enum.reduce(data, cols, &build_data(&1, &2, col_num))
    |> then(fn cols ->
      moves |> Enum.reverse() |> Enum.reduce(cols, fn line, res -> move(line, res) end)
    end)
    |> Enum.reduce([], fn {_k, v}, acc ->
      case v do
        nil -> acc
        [] -> acc
        [h | _] -> [h | acc]
      end
    end)
    |> Enum.reverse()
    |> Enum.join()
  end

  defp move(line, res) do
    [[_line, times, from, to]] = Regex.scan(~r/move (\d+) from (\d+) to (\d+)/, line)
    from = String.to_integer(from) - 1
    to = String.to_integer(to) - 1
    times = times |> String.to_integer() |> min(res[from] |> length)

    if times == 0 do
      res
    else
      1..times
      |> Enum.reduce(res, fn _idx, acc ->
        acc
        |> Map.replace(to, [hd(acc[from]) | acc[to]])
        |> Map.replace(from, tl(acc[from]))
      end)
    end
  end

  defp move2(line, res) do
    [[_line, times, from, to]] = Regex.scan(~r/move (\d+) from (\d+) to (\d+)/, line)
    from = String.to_integer(from) - 1
    to = String.to_integer(to) - 1
    times = times |> String.to_integer() |> min(res[from] |> length)

    if times == 0 do
      res
    else
      1..times
      |> Enum.reduce(res, fn idx, acc ->
        pos = ((res[from] |> length()) - 1) |> min(times - idx)
        {val, list} = acc[from] |> List.pop_at(pos)

        acc
        |> Map.replace(from, list)
        |> Map.replace(to, [val | acc[to]])
      end)
    end
  end

  defp build_data(line, res, col_num) do
    code_points = String.codepoints(line)

    1..col_num
    |> Enum.reduce(res, fn idx, acc ->
      code_points_idx = 4 * (idx - 1) + 1
      letter = Enum.at(code_points, code_points_idx)

      if letter != " " do
        Map.replace(acc, idx - 1, [letter | res[idx - 1]])
      else
        acc
      end
    end)
  end

  defp part2(input) do
    lines = String.split(input, "\n")

    %{data: data, moves: moves} =
      Enum.reduce(lines, %{data: [], moves: []}, fn line, acc ->
        cond do
          line == "" -> acc
          String.starts_with?(line, "move") -> %{acc | moves: [line | acc[:moves]]}
          line =~ "[" -> %{acc | data: [line | acc[:data]]}
          true -> acc
        end
      end)

    col_num = lines |> hd |> String.length() |> Kernel.+(1) |> div(4)
    cols = 0..(col_num - 1) |> Enum.reduce(%{}, fn idx, acc -> Map.put(acc, idx, []) end)

    Enum.reduce(data, cols, &build_data(&1, &2, col_num))
    |> then(fn cols ->
      moves |> Enum.reverse() |> Enum.reduce(cols, fn line, res -> move2(line, res) end)
    end)
    |> Enum.reduce([], fn {_k, v}, acc ->
      case v do
        nil -> acc
        [] -> acc
        [h | _] -> [h | acc]
      end
    end)
    |> Enum.reverse()
    |> Enum.join()
  end
end
