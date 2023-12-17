defmodule Day03One do
  @expected 4361

  @symbols ["*", "=", "#", "$", "@", "/", "-", "%", "&", "+"]
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    lines = String.split(input, "\n")
    next_lines_allowing_indexes = prev_next_lines_allowing_indexes(lines ++ [""])

    lines
    |> Enum.map_reduce(
      {MapSet.new(), next_lines_allowing_indexes},
      &parts_from_lines(&1, &2)
    )
    |> elem(0)
    |> List.flatten()
    |> Enum.sum()
  end

  defp parts_from_lines(
         line,
         {prev_line_allowing, [current_line_allowing | [next_line_allowing | _] = tail]}
       ) do
    %{parts: parts} =
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(
        %{
          building_number: "",
          number_start_index: 999,
          number_end_index: -1,
          prev_char: ".",
          last_index: String.length(line) - 1,
          allowing_indexes: {prev_line_allowing, next_line_allowing},
          parts: []
        },
        &build_and_check_part(&1, &2)
      )

    {parts, {current_line_allowing, tail}}
  end

  defp build_and_check_part(
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
        maybe_add_part(acc, ".")

      number?(char) ->
        acc

      true ->
        maybe_add_part(acc, char)
        |> Map.merge(%{building_number: "", number_start_index: 999, prev_char: char})
    end
  end

  defp check_is_part?(%{building_number: ""}, _), do: false

  defp check_is_part?(%{prev_char: prev_char}, next_char)
       when next_char in @symbols or prev_char in @symbols,
       do: true

  defp check_is_part?(
         %{
           number_start_index: number_start_index,
           number_end_index: number_end_index,
           allowing_indexes: {prev_line_allowing, next_line_allowing}
         },
         _next_char
       ) do
    MapSet.member?(prev_line_allowing, number_start_index) or
      MapSet.member?(next_line_allowing, number_start_index) or
      MapSet.member?(prev_line_allowing, number_end_index) or
      MapSet.member?(next_line_allowing, number_end_index)
  end

  defp maybe_add_part(%{building_number: building_number, parts: parts} = acc, next_char) do
    if check_is_part?(acc, next_char) do
      %{acc | parts: [String.to_integer(building_number) | parts]}
    else
      acc
    end
  end

  defp number?(char) do
    if char =~ ~r/\d/, do: true, else: false
  end

  defp prev_next_lines_allowing_indexes(lines) do
    Enum.map(lines, fn line ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(MapSet.new(), fn {char, index}, acc ->
        if char in @symbols do
          [index - 1, index, index + 1]
          |> MapSet.new()
          |> MapSet.union(acc)
        else
          acc
        end
      end)
    end)
  end
end
