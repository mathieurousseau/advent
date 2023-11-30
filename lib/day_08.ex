defmodule Day08 do
  @spec run(binary) :: {any, any}
  def run(input) do
    {part1(input), part2(input)}
  end

  defp part1(input) do
    {matrix, height, width} = create_matrix(input)

    result =
      for r <- 0..height do
        Enum.reduce(0..width, {MapSet.new(), <<47>>, <<47>>}, fn c,
                                                                 {visible, highest_left,
                                                                  highest_right} ->
          left_height = Map.get(matrix, {r, c})
          right_height = Map.get(matrix, {r, width - c})

          {visible, highest_left} = maybe_visible(visible, r, c, left_height, highest_left)

          {visible, highest_right} =
            maybe_visible(visible, r, width - c, right_height, highest_right)

          {visible, highest_left, highest_right}
        end)
      end
      |> Enum.reduce(MapSet.new(), fn {visible, _, _}, acc ->
        MapSet.union(acc, visible)
      end)

    for c <- 0..width do
      Enum.reduce(0..height, {MapSet.new(), <<47>>, <<47>>}, fn r,
                                                                {visible, highest_top,
                                                                 highest_bottom} ->
        top_height = Map.get(matrix, {r, c})
        bottom_height = Map.get(matrix, {height - r, c})

        {visible, highest_top} = maybe_visible(visible, r, c, top_height, highest_top)

        {visible, highest_bottom} =
          maybe_visible(visible, height - r, c, bottom_height, highest_bottom)

        {visible, highest_top, highest_bottom}
      end)
    end
    |> Enum.reduce(result, fn {visible, _, _}, acc ->
      MapSet.union(acc, visible)
    end)
    |> MapSet.size()
  end

  defp maybe_visible(visible, r, c, height, highest) when height > highest do
    {MapSet.put(visible, {r, c}), height}
  end

  defp maybe_visible(visible, _r, _c, _height, highest), do: {visible, highest}

  defp create_matrix(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce({%{}, 0, 0}, fn {line, r_idx}, acc ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {cp, c_idx}, {matrix, _, _} ->
        {Map.put(matrix, {r_idx, c_idx}, cp), r_idx, c_idx}
      end)
    end)
  end

  defp part2(input) do
    {matrix, height, width} = create_matrix(input)
    Map.keys(matrix) |> Enum.map(&scenic_score(&1, matrix, height, width)) |> Enum.max()
  end

  defp scenic_score({r, c}, matrix, height, width) do
    vert(r, c, matrix, 0) * vert(r, c, matrix, height) * horiz(r, c, matrix, 0) *
      horiz(r, c, matrix, width)
  end

  defp vert(r, c, matrix, to) do
    start_height = Map.get(matrix, {r, c})

    Enum.reduce_while(r..to, 0, fn r_i, acc ->
      cond do
        start_height > Map.get(matrix, {r_i, c}) -> {:cont, acc + 1}
        true -> {:halt, acc + 1}
      end
    end)
  end

  defp horiz(r, c, matrix, to) do
    start_height = Map.get(matrix, {r, c})

    Enum.reduce_while(c..to, 0, fn c_i, acc ->
      cond do
        start_height > Map.get(matrix, {r, c_i}) -> {:cont, acc + 1}
        true -> {:halt, acc + 1}
      end
    end)
  end
end
