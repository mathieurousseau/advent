defmodule Day08Two do
  @expected 6
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {starting_points, lr, map} = parse_data(input)

    Enum.map(starting_points, &walk(lr, [&1], lr, map, 0)) |> lcm()
  end

  defp gcd(a, 0), do: a
  defp gcd(0, b), do: b
  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp lcm(0, 0), do: 0
  defp lcm(a, b) when is_number(a) and is_number(b), do: div(a * b, gcd(a, b))

  defp lcm([a, b]) do
    lcm(a, b)
  end

  defp lcm([a | b]) do
    lcm(a, lcm(b))
  end

  defp walk(lr, current, path, map, count) do
    # Process.sleep(1000)
    # IO.inspect(current)

    if(
      Enum.all?(current, fn node ->
        String.ends_with?(node, "Z")
      end)
    ) do
      count
    else
      do_walk(lr, current, path, map, count)
    end
  end

  defp do_walk(lr, current, [l_or_r], map, count) do
    # Process.sleep(1000)
    next =
      Enum.map(current, fn node ->
        Map.get(map, {node, l_or_r})
      end)

    # [current, " - ", l_or_r] |> Enum.join() |> IO.inspect()
    walk(lr, next, lr, map, count + 1)
  end

  defp do_walk(lr, current, [next | rest], map, count) do
    next =
      Enum.map(current, fn node ->
        Map.get(map, {node, next})
      end)

    # Process.sleep(1000)
    # [current, " - ", next] |> Enum.join() |> IO.inspect()
    walk(lr, next, rest, map, count + 1)
  end

  defp parse_data(input) do
    lines = String.split(input, "\n", trim: true)
    [lr | map] = lines

    lr =
      lr
      |> String.graphemes()

    # |> Enum.reduce([], fn c, acc ->
    #   if c == "L" do
    #     [0 | acc]
    #   else
    #     [1 | acc]
    #   end
    # end)
    # |> Enum.reverse()

    {starting_points, map} =
      Enum.reduce(map, {[], %{}}, fn step, {starting_points, map} ->
        [key, targets] = String.split(step, " = ", trim: true)
        [l, r] = String.replace(targets, ~r/\(|\)|\s/, "") |> String.split(",", trim: true)

        map =
          Map.put(map, {key, "L"}, l)
          |> Map.put({key, "R"}, r)

        starting_points =
          if String.at(key, 2) == "A" do
            [key | starting_points]
          else
            starting_points
          end

        {starting_points, map}
      end)

    {starting_points, lr, map}
  end
end
