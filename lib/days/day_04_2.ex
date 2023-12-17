defmodule Day04Two do
  @expected 30
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
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
