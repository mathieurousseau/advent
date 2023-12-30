defmodule Aoc2023.Day25One do
  @expected 54
  def run(input, opts \\ []) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    graph = parse(input)

    solution =
      Stream.repeatedly(fn -> contract(graph) end)
      |> Enum.find(&(cut_size(&1, graph) == 3))

    [g1, g2] = Map.keys(solution) |> dbg

    MapSet.size(g1) * MapSet.size(g2)
  end

  defp contract(graph) when map_size(graph) == 2, do: graph

  defp contract(graph) do
    # Select random edge
    {a, a_edges} = Enum.random(graph)
    b = Enum.random(a_edges)
    b_edges = Map.get(graph, b)

    # create new node form A and B
    new_node = MapSet.union(a, b)

    # connect [a, b] to a connected nodes
    graph =
      Enum.reduce(a_edges, graph, fn vertex, graph ->
        graph
        |> Map.update!(vertex, &MapSet.delete(&1, a))
        |> Map.update!(vertex, &MapSet.put(&1, new_node))
        |> Map.update(new_node, MapSet.new([vertex]), &MapSet.put(&1, vertex))
      end)

    # connect [a, b] to b connected nodes

    graph =
      Enum.reduce(b_edges, graph, fn vertex, graph ->
        graph
        |> Map.update!(vertex, &MapSet.delete(&1, b))
        |> Map.update!(vertex, &MapSet.put(&1, new_node))
        |> Map.update(new_node, MapSet.new([vertex]), &MapSet.put(&1, vertex))
      end)
      |> Map.delete(a)
      |> Map.delete(b)
      |> Map.update!(new_node, &MapSet.delete(&1, a))
      |> Map.update!(new_node, &MapSet.delete(&1, b))

    contract(graph)
  end

  defp cut_size(contracted, graph) do
    [g1, g2] = Map.keys(contracted)

    g1_connected_nodes =
      Enum.reduce(g1, MapSet.new(), fn node, acc ->
        connected = Map.get(graph, MapSet.new([node]))

        connected =
          connected |> Enum.reduce(MapSet.new(), &MapSet.union(&2, &1))

        MapSet.union(acc, connected)
      end)

    MapSet.intersection(g1_connected_nodes, g2) |> MapSet.size()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, graph ->
      [n | rest] = String.split(line, [":", " "], trim: true)

      Enum.reduce(rest, graph, fn other_node, graph ->
        graph
        |> Map.update(
          MapSet.new([n]),
          MapSet.new([MapSet.new([other_node])]),
          &MapSet.put(&1, MapSet.new([other_node]))
        )
        |> Map.update(
          MapSet.new([other_node]),
          MapSet.new([MapSet.new([n])]),
          &MapSet.put(&1, MapSet.new([n]))
        )
      end)
    end)
  end
end
