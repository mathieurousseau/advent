defmodule Day05 do
  @expected {35, 46}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
    [seeds, steps] = String.split(input, "\n\n", parts: 2)
    "seeds: " <> seeds = seeds
    seeds = String.split(seeds, " ") |> Enum.map(&String.to_integer(&1))

    steps = get_steps_first(steps)

    Enum.reduce(seeds, 999_999_999_999_999_999_999, fn seed, lowest ->
      min(lowest, walk_the_steps(seed, steps))
    end)
  end

  defp walk_the_steps(seed, steps) do
    Enum.reduce(steps, seed, fn step_mapping, seed ->
      dest =
        Enum.reduce_while(step_mapping, seed, fn {to_range, from_range} = _mapping, seed ->
          dest =
            if seed in from_range do
              {:halt, seed + to_range.first - from_range.first}
            else
              {:cont, seed}
            end

          dest
        end)

      dest
    end)
  end

  defp get_steps_first(steps) do
    String.split(steps, "\n\n") |> Enum.map(&convert_to_tuple_first(&1))
  end

  defp convert_to_tuple_first(step) do
    {ranges, _} =
      String.split(step, "\n")
      |> tl
      |> Enum.map(fn map ->
        String.split(map, " ", trim: true) |> Enum.map(&String.to_integer(&1))
      end)
      |> Enum.sort(fn [_, from_1, _], [_, from_2, _] ->
        from_1 < from_2
      end)
      |> Enum.reduce({[], 0}, fn [to, from, range], {acc, min} ->
        from_range = from..(from + range - 1)
        to_range = to..(to + range - 1)

        if min < from do
          {
            [
              {to_range, from_range}
              | [
                  {min..(from_range.first - 1), min..(from_range.first - 1)}
                  | acc
                ]
            ],
            from_range.last + 1
          }
        else
          {[{to_range, from_range} | acc], from_range.last + 1}
        end
      end)

    {to_range, _} = hd(ranges)

    [{(to_range.last + 1)..9_999_999_999, (to_range.last + 1)..9_999_999_999} | ranges]
    |> Enum.reverse()
  end

  defp second(input) do
    [seeds, steps] = String.split(input, "\n\n", parts: 2)
    "seeds: " <> seeds = seeds

    seeds_ranges =
      String.split(seeds, " ")
      |> Enum.map(&String.to_integer(&1))
      |> Enum.chunk_every(2)
      |> Enum.sort(fn [from_1, _], [from_2, _] -> from_1 < from_2 end)
      |> Enum.map(fn [start, length] ->
        start..(start + length - 1)
      end)
      |> List.flatten()

    reversed_steps = get_steps_second(steps) |> Enum.reverse()

    seed = walk_the_steps_from_bottom(0..9_999_999_999, reversed_steps, seeds_ranges)

    steps = get_steps_first(steps)
    walk_the_steps(seed, steps)
  end

  defp walk_the_steps_from_bottom(current_range, [], seeds_ranges) do
    Enum.find(seeds_ranges, nil, fn seed_range ->
      not Range.disjoint?(current_range, seed_range)
    end)
    |> case do
      nil ->
        nil

      seed_range ->
        result = max(seed_range.first, current_range.first)
        result
    end
  end

  defp walk_the_steps_from_bottom(current_range, [step | rest] = _remaining_steps, seeds_ranges) do
    Enum.reduce_while(step, nil, fn {to_range, from_range}, _ ->
      cond do
        Range.disjoint?(current_range, to_range) ->
          {:cont, nil}

        true ->
          next_range_start =
            max(current_range.first, to_range.first) + from_range.first - to_range.first

          next_range_end =
            min(current_range.last, to_range.last) + from_range.first - to_range.first

          case walk_the_steps_from_bottom(next_range_start..next_range_end, rest, seeds_ranges) do
            nil ->
              {:cont, nil}

            result ->
              {:halt, result}
          end
      end
    end)
  end

  defp get_steps_second(steps) do
    String.split(steps, "\n\n") |> Enum.map(&convert_to_tuple_second(&1))
  end

  defp convert_to_tuple_second(step) do
    {ranges, _} =
      String.split(step, "\n")
      |> tl
      |> Enum.map(fn map ->
        String.split(map, " ", trim: true) |> Enum.map(&String.to_integer(&1))
        # {from..(from + range - 1), to, to - from}
      end)
      |> Enum.sort(fn [to_1, _, _], [to_2, _, _] ->
        to_1 < to_2
      end)
      |> Enum.reduce({[], 0}, fn [to, from, range], {acc, min} ->
        from_range = from..(from + range - 1)
        to_range = to..(to + range - 1)

        if min < to do
          {
            [
              {to_range, from_range}
              | [
                  {min..(to_range.first - 1), min..(from_range.first - 1)}
                  | acc
                ]
            ],
            to_range.last + 1
          }
        else
          {[{to_range, from_range} | acc], to_range.last + 1}
        end
      end)

    {to_range, _} = hd(ranges)

    [{(to_range.last + 1)..9_999_999_999, (to_range.last + 1)..9_999_999_999} | ranges]
    |> Enum.reverse()
  end
end
