defmodule Day18One do
  @expected 62
  def run(input) do
    {do_run(input), @expected}
  end

  @map %{
    r: {0, 1},
    l: {0, -1},
    u: {-1, 0},
    d: {1, 0}
  }

  defp do_run(input) do
    # |> IO.inspect(limit: :infinity)
    {_, coords, contour} = parse(input) |> build_coordinates()

    area = coords |> shoelace()
    {area, contour}
    area + div(contour, 2) + 1
  end

  defp shoelace(coords) do
    {_, area} =
      Enum.reduce(coords, {coords, 0}, fn
        _, {[{x1, y1} | [{x2, y2} = s | r]], sum} ->
          sum = sum + x1 * y2 - x2 * y1
          {[s | r], sum}

        _, acc ->
          acc
      end)

    area |> abs() |> div(2)
  end

  defp build_coordinates(list) do
    start = {0, 0}
    coords = [start]

    # {_, coords, contour} =
    Enum.reduce(list, {start, coords, 0}, fn [d, n, _], {{x, y}, coords, contour} ->
      {x_offset, y_offset} = Map.get(@map, d)
      next_coordinate = {x + n * x_offset, y + n * y_offset}
      {next_coordinate, [next_coordinate | coords], contour + n}
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [d, n, c] = String.split(line, " ", trim: true)

      [String.downcase(d) |> String.to_atom(), String.to_integer(n), c]
    end)
  end
end
