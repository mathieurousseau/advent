defmodule Aoc2023.Day03Two do
  @expected 467_835

  @symbols ["*", "=", "#", "$", "@", "/", "-", "%", "&", "+"]
  def run(input) do
    {do_run(input), @expected}
  end

  defp number?(char) do
    if char =~ ~r/\d/, do: true, else: false
  end

  defp do_run(input) do
    lines = String.split(input, "\n") |> Enum.map(&String.replace(&1, ~r/[^\d|*]/, "."))

    star_indexes = star_indexes(lines ++ [""])

    lines
    |> Enum.with_index()
    |> Enum.map_reduce(
      {MapSet.new(), star_indexes},
      &gears_from_lines(&1, &2)
    )
    |> elem(0)
    |> Enum.reduce(%{}, fn line_star, acc ->
      Map.merge(line_star, acc, fn _key, existing, new ->
        existing = existing || []
        existing ++ new
      end)
    end)
    |> Map.values()
    |> Enum.reject(&(length(&1) < 2))
    |> Enum.reduce(0, fn connected_gears, total -> Enum.product(connected_gears) + total end)
  end

  defp gears_from_lines(
         {line, line_index},
         {prev_line_stars, [current_line_stars | [next_line_stars | _] = tail]}
       ) do
    %{gears: gears} =
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(
        %{
          building_number: "",
          number_start_index: 999,
          number_end_index: -1,
          prev_char: ".",
          prev_char_index: -1,
          last_index: String.length(line) - 1,
          star_indexes: {prev_line_stars, next_line_stars},
          connecting_stars: [],
          gears: %{},
          line_index: line_index
        },
        &build_and_check_gears(&1, &2)
      )

    {gears, {current_line_stars, tail}}
  end

  defp build_and_check_gears(
         {char, index},
         %{
           building_number: building_number,
           number_start_index: number_start_index,
           last_index: last_index
         } = acc
       ) do
    acc =
      if number?(char) do
        %{
          acc
          | building_number: building_number <> char,
            number_end_index: index,
            number_start_index: min(number_start_index, index)
        }
      else
        acc
      end

    cond do
      index == last_index ->
        maybe_add_gear(acc, {".", -1})

      number?(char) ->
        acc

      true ->
        maybe_add_gear(acc, {char, index})
        |> Map.merge(%{
          building_number: "",
          number_start_index: 999,
          prev_char: char,
          prev_char_index: index
        })
    end
  end

  defp connecting_stars(%{building_number: ""}, _), do: nil

  defp connecting_stars(
         %{
           number_start_index: number_start_index,
           number_end_index: number_end_index,
           prev_char: prev_char,
           prev_char_index: prev_char_index,
           line_index: line_index,
           star_indexes: {prev_line_stars, next_line_stars}
         },
         {next_char, next_char_index}
       ) do
    star_before = if prev_char == "*", do: [{line_index, prev_char_index}]

    star_after = if next_char == "*", do: [{line_index, next_char_index}]

    ([star_before, star_after] ++
       for {stars_indexes, star_line_index} <- [
             {prev_line_stars, line_index - 1},
             {next_line_stars, line_index + 1}
           ],
           number_index <- [number_start_index, number_end_index] do
         Enum.map(stars_indexes, fn star ->
           if number_index in [star - 1, star, star + 1], do: {star_line_index, star}
         end)
       end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.reject(&is_nil(&1))
  end

  defp maybe_add_gear(%{building_number: building_number, gears: gears} = acc, next_char) do
    case connecting_stars(acc, next_char) do
      [_ | _] = connected_stars ->
        gears =
          Enum.reduce(connected_stars, gears, fn star, gears ->
            {_, acc} =
              Map.get_and_update(gears, star, fn
                nil ->
                  {nil, [String.to_integer(building_number)]}

                current_value ->
                  {current_value, [String.to_integer(building_number) | current_value]}
              end)

            acc
          end)

        %{acc | gears: gears}

      _ ->
        acc
    end
  end

  defp star_indexes(lines) do
    Enum.map(lines, fn line ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(MapSet.new(), fn {char, index}, acc ->
        if char == "*" do
          MapSet.put(acc, index)
        else
          acc
        end
      end)
    end)
  end
end
