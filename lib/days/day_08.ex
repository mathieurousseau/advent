defmodule Day08 do
  @expected {6, "TBD"}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
    {starting_points, lr, map} = parse_data(input)

    Enum.map(starting_points, &(walk(lr, [&1], lr, map, 0) |> IO.inspect())) |> lcm()

    s = NaiveDateTime.utc_now()
    NaiveDateTime.diff(NaiveDateTime.utc_now(), s, :second) |> IO.inspect(label: "took:")
    IO.inspect(s)
    walk(lr, starting_points, lr, map, 0) |> IO.inspect(label: "result")
    IO.inspect(NaiveDateTime.utc_now())
    NaiveDateTime.diff(NaiveDateTime.utc_now(), s, :second) |> IO.inspect(label: "took:")
  end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b) when is_number(a) and is_number(b), do: div(a * b, gcd(a, b))

  def lcm([a, b]) do
    lcm(a, b)
  end

  def lcm([a | b]) do
    lcm(a, lcm(b))
  end

  defp walk(_, nil, _, _, _count), do: raise("nil")

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

  defp second(_input) do
  end
end
