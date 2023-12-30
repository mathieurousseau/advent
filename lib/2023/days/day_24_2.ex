defmodule Aoc2023.Day24Two do
  defmodule Segment do
    defstruct id: nil,
              x: nil,
              y: nil,
              z: nil,
              xv: nil,
              yv: nil,
              zv: nil,
              m: nil,
              yi: nil,
              a: nil,
              b: nil,
              c: nil
  end

  # Line equation y = mx + yi
  # m = abs(yv / xv)
  # yi = y - mx => mx - y + yi = 0
  # General form = ax + by + c = 0
  # a = m, b = -1, c = yi
  # intersection from https://www.cuemath.com/geometry/intersection-of-two-lines/
  # [ (b1 * c2 - b2 * c1) / (a1 * b2 - a2 * b1) , (c1 * a2 - c2 * a1) / (a1 * b2 - a2 * b1) ]
  #
  @expected 47
  # @expected {24.0, 13.0}
  @input %{test: [7, 27], real: [200_000_000_000_000, 400_000_000_000_000]}
  def run(input, test) do
    input_options = if test, do: @input[:test], else: @input[:real]
    {do_run(input, input_options), @expected}
  end

  defp do_run(input, [low, high]) do
    {segments, max_velocity} =
      parse(input)

    segments_map =
      Enum.reduce(segments, %{}, fn segment, acc -> Map.put(acc, segment.id, segment) end)

    # min_velocity = 200
    # max_velocity = 2

    velocities =
      for r_x_v <- -max_velocity..max_velocity,
          r_y_v <- -max_velocity..max_velocity do
        {r_x_v, r_y_v}
      end
      |> Enum.sort(fn {x1, y1}, {x2, y2} -> abs(x1) + abs(y1) < abs(x2) + abs(y2) end)

    segment_checks =
      for s1 <- 0..(length(segments) - 1), s2 <- 0..(length(segments) - 1), s1 != s2 do
        MapSet.new([s1, s2])
      end
      |> MapSet.new()
      |> MapSet.to_list()
      |> Enum.map(fn mapset -> MapSet.to_list(mapset) end)
      |> Enum.sort(fn [a1, b1], [a2, b2] -> a1 + b1 < a2 + b2 end)

    {{xv, _yv}, {_, {rx, ry}}} =
      Enum.reduce_while(velocities, nil, fn velocity, _ ->
        case all_intersect_on_same_point(segments_map, velocity, segment_checks) do
          nil -> {:cont, nil}
          found -> {:halt, {velocity, found}}
        end
      end)

    velocities =
      -max_velocity..max_velocity |> Enum.map(fn z_velocity -> {xv, z_velocity} end)

    segments = segments |> Enum.map(fn s -> %{s | y: s.z, yv: s.zv} end)

    segments_map =
      Enum.reduce(segments, %{}, fn segment, acc -> Map.put(acc, segment.id, segment) end)

    {_, {_rx, rz}} =
      Enum.reduce_while(velocities, nil, fn velocity, _ ->
        case all_intersect_on_same_point(segments_map, velocity, segment_checks) do
          nil -> {:cont, nil}
          found -> {:halt, found}
        end
      end)

    rx + ry + rz
  end

  defp shift_segments(segment, {xv, yv}) do
    %{segment | xv: segment.xv - xv, yv: segment.yv - yv}
  end

  defp all_intersect_on_same_point(segments_map, velocity, segment_checks) do
    rock =
      Enum.reduce_while(segment_checks, {0, {0, 0}}, fn [s1_id, s2_id],
                                                        {times, {rx, ry}} = rock ->
        s1 = Map.get(segments_map, s1_id) |> shift_segments(velocity) |> calculate_equation()
        s2 = Map.get(segments_map, s2_id) |> shift_segments(velocity) |> calculate_equation()

        case find_intersection(s1, s2) do
          nil ->
            {:cont, rock}

          {_, _, x, y} = intersection ->
            cond do
              in_past?(intersection) ->
                {:halt, nil}

              rock == {0, {0, 0}} ->
                {:cont, {1, {x, y}}}

              rock == {3, {x, y}} ->
                {:halt, rock}

              rx == x and ry == y ->
                {:cont, {times + 1, {rx, ry}}}

              rx != x or ry != y ->
                {:halt, nil}
            end
        end
      end)

    rock
  end

  defp in_past?(
         {%Segment{x: x1, y: y1, xv: xv1, yv: yv1}, %Segment{x: x2, y: y2, xv: xv2, yv: yv2}, xi,
          yi}
       ) do
    (xi > x1 and xv1 < 0) or (xi < x1 and xv1 > 0) or
      (yi > y1 and yv1 < 0) or (yi < y1 and yv1 > 0) or
      (xi > x2 and xv2 < 0) or (xi < x2 and xv2 > 0) or
      (yi > y2 and yv2 < 0) or (yi < y2 and yv2 > 0)
  end

  defp calculate_equation(%Segment{x: _x, y: _y, xv: 0, yv: _yv} = _segment), do: nil

  defp calculate_equation(%Segment{x: x, y: y, xv: xv, yv: yv} = segment) do
    m = yv / xv
    yi = y - m * x
    %{segment | m: m, yi: yi, a: m, b: -1, c: yi}
  end

  defp find_intersection(nil, _), do: nil
  defp find_intersection(_, nil), do: nil

  defp find_intersection(%{a: a1, b: b1, c: c1, m: m1} = s1, %{a: a2, b: b2, c: c2, m: m2} = s2) do
    if(m1 != m2) do
      [ix, iy] = [
        (b1 * c2 - b2 * c1) / (a1 * b2 - a2 * b1),
        (c1 * a2 - c2 * a1) / (a1 * b2 - a2 * b1)
      ]

      {s1, s2, round(ix), round(iy)}
    else
      nil
    end
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.map_reduce(0, fn {line, idx}, acc ->
      [[_ | data]] =
        Regex.scan(~r/(\d+), (\d+), (\d+) @ (.*\d+), (.*\d+), (.*\d+)/, line)

      # data
      [x, y, z, xv, yv, zv] =
        data
        |> Enum.map(fn v ->
          v |> String.trim() |> String.to_integer()
        end)

      acc = acc |> max(abs(xv)) |> max(abs(yv)) |> max(abs(zv))

      {%Segment{id: idx, x: x, y: y, z: z, xv: xv, yv: yv, zv: zv}, acc}
    end)
  end
end
