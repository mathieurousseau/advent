defmodule Day18One do
  @expected 62
  def run(input) do
    {do_run(input), @expected}
  end

  # @map %{
  #   "R" => :r
  #   "L" => :l
  #   "R" => :u
  #   "R" => :r
  # }
  defp do_run(input) do
    # |> IO.inspect(limit: :infinity)
    parsed = parse(input)
    next = parsed |> hd |> hd

    # dig(:r)

    {map, _, _, start_i, start_j, h, w, _} = dig(parsed, {%{}, 0, 0, 0, 0, 0, 0, next})
    # |> print()

    # dbg(start_i)
    # dbg(start_j)

    # Map.get(map, {0.0}) |> dbg
    # Map.get(map, {0, 0}) |> dbg
    # map = Map.put(map, {0, 0}, [:u, :r])

    # Map.keys(map)
    # |> dbg
    # |> Enum.sort(fn {i1, j1}, {i2, j2} ->
    #   if i1 == i2 do
    #     j1 < j2
    #   else
    #     i1 < j2
    #   end
    # end)
    # |> dbg

    # Map.keys(map) |> length() |> dbg

    {inside, countour} =
      {Day10Two.count_inner(map, :u, :r,
         # Day10Two.count_inner(map, :d, :l,
         start_i: start_i,
         start_j: start_j,
         h: h,
         w: w
       ), map_size(map)}

    # |> dbg

    inside + countour
  end

  defp print({map, _, _, start_i, start_j, h, w, _} = ctx) do
    # dbg(start_i)
    # dbg(start_j)

    start_i..h
    |> Enum.each(fn i ->
      start_j..w
      |> Enum.each(fn j ->
        case Map.get(map, {i, j}) do
          nil -> IO.write(".")
          d -> convert(d) |> IO.write()
        end
      end)

      IO.write("\n")
    end)

    ctx
  end

  defp convert(d) do
    # "#"
    d = MapSet.new(d)

    cond do
      d == MapSet.new([:u, :r]) -> "X"
      d == MapSet.new([:u]) -> "|"
      d == MapSet.new([:d]) -> "|"
      d == MapSet.new([:r]) -> "-"
      d == MapSet.new([:l]) -> "-"
      d == MapSet.new([:u, :l]) -> "X"
      d == MapSet.new([:d, :r]) -> "X"
      d == MapSet.new([:d, :l]) -> "X"
      true -> "."
    end
  end

  # defp dig(steps) do
  #   Enum.reduce(steps, {%{}, 0, 0, 0, 0, 0, 0, previous}, fn [d, n, _],
  #                                                            {map, i, j, start_i, start_j, h, w,
  #                                                             previous} = ctx ->
  defp dig([], ctx), do: ctx

  defp dig(
         [[d, n, _] | rest],
         {map, i, j, start_i, start_j, h, w, first} = ctx
       ) do
    next =
      case rest do
        nil -> first
        [] -> first
        [[d, _, _] | _] -> d
      end

    next_ctx =
      1..n
      |> Enum.reduce(ctx, fn idx, {map, i, j, start_i, start_j, h, w, _first} = ctx ->
        {map, i, j, start_i, start_j, h, w, d} =
          case d do
            :l ->
              j = j - 1
              start_j = if start_j < j, do: start_j, else: j
              {map, i, j, start_i, start_j, h, w, d}

            :r ->
              j = j + 1
              w = if j > w, do: j, else: w
              {map, i, j, start_i, start_j, h, w, d}

            :u ->
              i = i - 1
              start_i = if start_i < i, do: start_i, else: i
              {map, i, j, start_i, start_j, h, w, d}

            :d ->
              i = i + 1
              h = if i > h, do: i, else: h
              {map, i, j, start_i, start_j, h, w, d}

            _ ->
              raise("no good")
          end

        # {_, map} =
        #   Map.get_and_update(map, {i, j}, fn
        #     nil -> {nil, MapSet.new([previous, d])}
        #     current -> {current, MapSet.union(current, MapSet.new([previous, d]))}
        #   end)
        map =
          if idx == n do
            Map.put(map, {i, j}, [next, d])
          else
            Map.put(map, {i, j}, [d])
          end

        {map, i, j, start_i, start_j, h, w, first}
      end)

    dig(rest, next_ctx)
  end

  #   end)
  # end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [d, n, c] = String.split(line, " ", trim: true)

      [String.downcase(d) |> String.to_atom(), String.to_integer(n), c]
    end)
  end
end
