defmodule Day04 do
  @expected {13, 30}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
    String.split(input, "\n")
    |> Enum.map(&calculate_line(&1))
    |> Enum.reduce(0, fn line_results, acc -> acc + line_results end)
  end

  defp calculate_line(line) do
    [_, winning, chosen] =
      Regex.scan(~r/Card\s+\d+:(.*) \| (.*)/, line)
      |> List.flatten()

    winning_set = String.split(winning, " ", trim: true) |> MapSet.new()

    chosen_set = String.split(chosen, " ", trim: true) |> MapSet.new()

    right_numbers_size = MapSet.intersection(winning_set, chosen_set) |> MapSet.size()

    case right_numbers_size do
      0 -> 0
      _ -> :math.pow(2, right_numbers_size - 1)
    end
  end

  defp second(input) do
    cards =
      String.split(input, "\n")
      |> Enum.map(&calculate_line_2(&1))
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line_winners, index}, acc ->
        Map.put(acc, index, {1, line_winners})
      end)

    total_cards = Map.keys(cards) |> Enum.sort() |> Enum.reduce(cards, &process_cards(&1, &2))

    Map.values(total_cards) |> Enum.reduce(0, fn {count, _}, acc -> acc + count end)
  end

  defp process_cards(card_id, cards) do
    {card_count, card_winners} = Map.get(cards, card_id)

    if card_winners == 0 do
      cards
    else
      1..card_winners//1
      |> Enum.to_list()
      |> Enum.reduce(cards, fn number, cards ->
        {_, cards} =
          Map.get_and_update(cards, card_id + number, fn
            nil ->
              {nil, {0, 0}}

            {next_card_count, next_card_winners} = current_value ->
              {current_value, {next_card_count + card_count, next_card_winners}}
          end)

        cards
      end)
    end
  end

  defp calculate_line_2(line) do
    [_, winning, chosen] =
      Regex.scan(~r/Card\s+\d+:(.*) \| (.*)/, line)
      |> List.flatten()

    winning_set = String.split(winning, " ", trim: true) |> MapSet.new()

    chosen_set = String.split(chosen, " ", trim: true) |> MapSet.new()

    MapSet.intersection(winning_set, chosen_set) |> MapSet.size()
  end
end
