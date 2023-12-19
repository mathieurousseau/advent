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

  defp calc([], g, acc), do: 0
  defp calc([_], g, acc), do: 0

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
            g = Graph.add_edge(g, from, to, weight: weight)
          end)
        end)
      end)
    end)
  end

  defp starter_min() do
  end

  defp walk(_, {{i, j}, _}, _, h, w, _, ctx) when i < 0 or j < 0 or i >= h or j >= w,
    do: {nil, ctx}

  defp walk(_, _, heat_loss, _, _, _min_heat_loss, {_memo, _visiting, min_heat_loss} = ctx)
       when heat_loss > min_heat_loss,
       do: {nil, ctx}

  defp walk(map, {{i, j} = point, _}, heat_loss, h, w, _, {memo, visiting, min_heat_loss})
       when i == h - 1 and j == w - 1 do
    # tile_loss = Map.get(map, point)
    min_heat_loss = min(heat_loss, min_heat_loss)
    # if heat_loss + tile_loss == 19, do: raise("stop")
    {min_heat_loss, {memo, visiting, min_heat_loss}}
    # min(heat_loss + tile_loss, min_heat_loss)
  end

  defp walk(
         map,
         {point, to} = key,
         heat_loss,
         h,
         w,
         current_min,
         {memo, visiting, min_heat_loss} = originl_ctx
       ) do
    # {memo, visiting} = Agent.get(:memo, fn state -> state end)
    # IO.puts(map_size(memo))
    # IO.puts(MapSet.size(visiting))
    # IO.puts("")
    tile_loss = Map.get(map, point)
    prev = Map.get(memo, key)
    skip = MapSet.member?(visiting, key)
    # prev = nil

    cond do
      skip ->
        {nil, originl_ctx}

      not is_nil(prev) and prev <= heat_loss ->
        prev

      true ->
        # Agent.update(:memo, fn {memo, visiting} ->
        #   {memo, MapSet.put(visiting, key)}
        # end)

        visiting = MapSet.put(visiting, key)

        # if point == {0, 4} do
        # IO.puts("#{inspect(point)} / #{to} / #{tile_loss} / #{heat_loss} -> #{min_heat_loss}")

        # end

        # Process.sleep(500)

        {res, {memo, visiting, min_heat_loss}} =
          do_walk(map, {point, to}, heat_loss, h, w, current_min, {memo, visiting, min_heat_loss})

        # res = min(res, current_min)
        ctx = {Map.put(memo, key, res), MapSet.delete(visiting, key), min_heat_loss}
        # if point == {0, 4} do
        #   IO.inspect(res)
        # end

        {res, ctx}
    end
  end

  defp do_walk(map, {point, to} = key, heat_loss, h, w, _current_min, ctx) do
    # tile_loss = Map.get(map, point)

    # IO.inspect("#{inspect(key)} - #{heat_loss}")

    next_steps = next_steps(point, to, map)

    {min_ahead, ctx, tile_loss} =
      Enum.reduce(next_steps, {nil, ctx, 0}, fn {n_point, n_to, n_cost},
                                                {current_min, ctx, _cost} ->
        case walk(map, {n_point, n_to}, heat_loss + n_cost, h, w, current_min, ctx) do
          {nil, ctx} ->
            {nil, ctx, 0}

          {this_min, ctx} ->
            {min(current_min, this_min), ctx, n_cost}
        end
      end)

    # Agent.update(:memo, fn {memo, visiting} ->
    #   {Map.put(memo, key, min_ahead), MapSet.delete(visiting, key)}
    # end)
    if is_nil(min_ahead) do
      {nil, ctx}
    else
      {min_ahead + tile_loss, ctx}
    end
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
