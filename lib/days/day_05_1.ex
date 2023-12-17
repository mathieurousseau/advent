defmodule Day05One do
  @expected 35
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
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
end
