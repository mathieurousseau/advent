defmodule Day18Two do
  # @expected 62
  @expected 952_408_144_115
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

    IO.puts("dug")

    blocks =
      Map.values(map)
      |> Enum.reduce(0, fn row, count ->
        count + length(row)
      end)

    map = map |> Enum.map(& &1)
    IO.puts("mapped")
    map = Enum.sort(map, fn {k, _v}, {k2, _v2} -> k < k2 end)
    IO.puts("sorted")

    map =
      map
      |> Enum.map(fn {_k, v} ->
        Enum.sort(v, fn {j1, _}, {j2, _} -> j1 < j2 end)
      end)

    # |> dbg

    IO.puts("values extracted and sorted")
    # print(map, start_j, w)

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
      {find_tiles_from_left(map, :u,
         # Day10Two.count_inner(map, :d, :l,
         start_i: start_i,
         start_j: start_j,
         h: h,
         w: w
       ), blocks}
      |> dbg

    inside + countour
  end

  defp print(map, start_j, w) do
    map
    |> Enum.each(fn row ->
      {last_j, last_d} =
        row
        |> Enum.reduce({start_j - 1, [nil]}, fn {idx, d}, {prev_j, prev_dir} ->
          (prev_j + 1)..(idx - 1)//1 |> Enum.each(fn _ -> IO.write(".") end)
          d |> convert() |> IO.write()
          {idx, d}
          # case Map.get(map, {i, j}) do
          #   nil -> IO.write(".")
          #   d -> convert(d) |> IO.write()
          # end
        end)

      # last_d |> convert() |> IO.write()
      (last_j + 1)..w//1 |> Enum.each(fn _ -> IO.write(".") end)
      IO.write("\n")
    end)
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

  # defp convert_prev(d) do
  #   # "#"
  #   d = MapSet.new(d)

  #   cond do
  #     d == MapSet.new([:u, :r]) -> "X"
  #     d == MapSet.new([:u]) -> "|"
  #     d == MapSet.new([:d]) -> "|"
  #     d == MapSet.new([:r]) -> "-"
  #     d == MapSet.new([:l]) -> "-"
  #     d == MapSet.new([:u, :l]) -> "X"
  #     d == MapSet.new([:d, :r]) -> "X"
  #     d == MapSet.new([:d, :l]) -> "X"
  #     true -> "."
  #   end
  # end

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
            {_, map} =
              Map.get_and_update(map, i, fn
                nil -> {nil, [{j, [next, d]}]}
                current -> {current, [{j, [next, d]} | current]}
              end)

            map
          else
            {_, map} =
              Map.get_and_update(map, i, fn
                nil -> {nil, [{j, [d]}]}
                current -> {current, [{j, [d]} | current]}
              end)

            map
          end

        {map, i, j, start_i, start_j, h, w, first}
      end)

    dig(rest, next_ctx)
  end

  def find_tiles_from_left(map, inside_toggler, opts) do
    # IO.inspect(inside_toggler)
    # start_i = Keyword.get(opts, :start_i) |> dbg
    start_j = Keyword.get(opts, :start_j) |> dbg
    # r_l = Keyword.get(opts, :h) |> dbg
    # c_l = Keyword.get(opts, :w) |> dbg

    map = map |> Enum.with_index()

    Enum.reduce(map, 0, fn {row, idx}, count ->
      # IO.puts("#{idx}")
      # IO.inspect(row)

      {count, _, _} =
        Enum.reduce(row, {count, 0, start_j}, fn {idx, direction}, {count, inside, prev} ->
          count = count + (idx - prev - 1) * inside

          case direction do
            [_ | _] = direction ->
              inside =
                if inside_toggler in direction do
                  1
                else
                  0
                end

              # IO.write(".")
              {count, inside, idx}

            _direction ->
              {count, inside, idx}
              # if inside == 1 do
              #   # IO.write("1")
              #   {MapSet.put(tiles, {r, c}), inside}
              # else
              #   # IO.write(" ")

              #   {tiles, inside}
              # end
          end
        end)

      # IO.write("\n")
      count
    end)
  end

  #   end)
  # end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [d, n, c] = String.split(line, " ", trim: true)
      n = String.slice(c, 2, 5)
      d = String.slice(c, 7, 1)

      d =
        case String.to_integer(d) do
          0 -> :r
          1 -> :d
          2 -> :l
          3 -> :u
        end

      n = String.to_integer(n, 16)

      [d, n, c]
      # [String.downcase(d) |> String.to_atom(), String.to_integer(n), c]
    end)
  end
end
