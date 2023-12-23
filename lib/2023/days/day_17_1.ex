defmodule Aoc2023.Day17One do
  @expected 102
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    # Agent.start_link(fn -> {%{}, MapSet.new()} end, name: :memo)

    {map, h, w} = Aoc.to_matrix_map(input, fn s -> String.to_integer(s) end)
    Map.get(map, {h - 1, w - 1})
    # - start_heat_loss
    g = build_graph(map, h - 1, w - 1)

    one = Graph.dijkstra(g, {0, 0}, {h - 1, w - 1, :right}) |> calc(g, 0)

    two = Graph.dijkstra(g, {0, 0}, {h - 1, w - 1, :down}) |> calc(g, 0)
    # Graph.dijkstra(g, {0, 0, :down}, {h - 1, w - 1, :right}) |> dbg
    # Graph.dijkstra(g, {0, 0, :down}, {h - 1, w - 1, :down}) |> dbg
    # {_, {_, _, res_2}} = walk(map, {{0, 0}, :right}, 0, h, w, nil, {%{}, MapSet.new(), nil})
    # {_, {_, _, res_2}} = walk(map, {{0, 0}, :right}, 0, h, w, nil, {%{}, MapSet.new(), nil})
    # {_, {_, _, res_2}} = walk(map, {{0, 0}, :down, 0}, 0, h, w, nil, ctx)
    # {memo, visiting} = Agent.get(:memo, fn state -> state end)

    # memo
    # |> Enum.each(fn
    #   {{{0, 4}, _, _}, _} = m -> IO.inspect(m)
    #   _ -> nil
    # end)

    # res_2
    min(one, two)
  end

  defp calc([], _g, _acc), do: 0
  defp calc([_], _g, _acc), do: 0

  defp calc([from | [to | rest]], g, acc) do
    acc + Graph.edge(g, from, to).weight + calc([to | rest], g, acc)
  end

  @directions [:down, :right, :up, :left]

  defp build_graph(map, h, w) do
    g = Graph.new()
    g = g |> Graph.add_vertex({0, 0}) |> Graph.add_vertex({0, 0})

    0..h
    |> Enum.reduce(g, fn i, g ->
      0..w
      |> Enum.reduce(g, fn j, g ->
        @directions
        |> Enum.reduce(g, fn direction, g ->
          from =
            if i == 0 and j == 0 do
              {i, j}
            else
              {i, j, direction}
            end

          g = Graph.add_vertex(g, from)

          next_steps({i, j}, direction, map)
          |> Enum.reduce(g, fn {{v_i, v_j}, direction, weight}, g ->
            to = {v_i, v_j, direction}
            g = Graph.add_vertex(g, to)
            Graph.add_edge(g, from, to, weight: weight)
          end)
        end)
      end)
    end)
  end

  @opposites %{left: :right, right: :left, up: :down, down: :up}
  defp next_steps(point, direction, map) do
    directions =
      cond do
        direction in [:right, :left] -> [:down, :up]
        direction in [:down, :up] -> [:right, :left]
        true -> @directions
      end

    # 1..3
    # |> Enum.reduce([], fn i, acc ->
    Enum.map(directions, fn direction ->
      {next_points, _} =
        1..3
        |> Enum.reduce({[], 0}, fn offset, {acc, cost} ->
          next = next(direction, point, offset, cost, map)

          if next do
            {_next_point, _to, cost} = next
            {[next | acc], cost}
          else
            {acc, cost}
          end
        end)

      next_points
    end)
    |> Enum.reject(&is_nil(&1))
    |> List.flatten()

    # end)
  end

  defp next(to, {i, j} = _point, offset, prev_cost, map) do
    next_point =
      case to do
        :left -> {i, j - offset}
        :right -> {i, j + offset}
        :up -> {i - offset, j}
        :down -> {i + offset, j}
      end

    if Map.get(map, next_point) do
      {next_point, to, prev_cost + Map.get(map, next_point)}
    else
      nil
    end
  end
end