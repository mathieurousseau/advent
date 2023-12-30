defmodule Aoc2023.Day24One do
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

  @expected 2
  @input %{test: [7, 27], real: [200_000_000_000_000, 400_000_000_000_000]}
  @spec run(binary(), any()) :: {non_neg_integer(), 2}
  def run(input, test) do
    input_options = if test, do: @input[:test], else: @input[:real]
    {do_run(input, input_options), @expected}
  end

  defp do_run(input, [low, high]) do
    segments = parse(input) |> Enum.map(&calculate_equation(&1))

    for s1 <- segments, s2 <- segments do
      if(s1 != s2) do
        find_intersection(s1, s2)
      end
    end
    |> Enum.reject(&is_nil(&1))
    |> Enum.reject(&outside?(&1, low, high))
    |> Enum.count()
    |> div(2)
  end

  defp outside?(
         {%Segment{x: x1, y: y1, xv: xv1, yv: yv1}, %Segment{x: x2, y: y2, xv: xv2, yv: yv2}, xi,
          yi},
         low,
         high
       ) do
    xi < low or xi > high or yi < low or yi > high or
      (xi > x1 and xv1 < 0) or (xi < x1 and xv1 > 0) or
      (yi > y1 and yv1 < 0) or (yi < y1 and yv1 > 0) or
      (xi > x2 and xv2 < 0) or (xi < x2 and xv2 > 0) or
      (yi > y2 and yv2 < 0) or (yi < y2 and yv2 > 0)
  end

  defp calculate_equation(%Segment{x: x, y: y, xv: xv, yv: yv} = segment) do
    m = yv / xv
    yi = y - m * x
    %{segment | m: m, yi: yi, a: m, b: -1, c: yi}
  end

  defp find_intersection(%{a: a1, b: b1, c: c1, m: m1} = s1, %{a: a2, b: b2, c: c2, m: m2} = s2) do
    if(m1 != m2) do
      [ix, iy] = [
        (b1 * c2 - b2 * c1) / (a1 * b2 - a2 * b1),
        (c1 * a2 - c2 * a1) / (a1 * b2 - a2 * b1)
      ]

      {s1, s2, ix, iy}
    end
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.map(fn {line, idx} ->
      [[_ | data]] =
        Regex.scan(~r/(\d+), (\d+), (\d+) @ (.*\d+), (.*\d+), (.*\d+)/, line)

      # data
      [x, y, z, xv, yv, zv] =
        data
        |> Enum.map(fn v ->
          v |> String.trim() |> String.to_integer()
        end)

      %Segment{id: idx, x: x, y: y, z: z, xv: xv, yv: yv, zv: zv}
    end)
  end
end
