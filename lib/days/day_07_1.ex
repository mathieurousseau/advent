defmodule Day07One do
  @expected 6440
  def run(input) do
    {do_run(input), @expected}
  end

  @card_order Stream.zip(~w(A K Q T 9 8 7 6 5 4 3 2 J), 14..1) |> Enum.into(%{})

  defp do_run(input) do
    list = parse_data(input)

    Enum.map(list, fn {hand, _} ->
      hand
    end)
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.uniq()

    Enum.sort(list, fn {hand_1, _}, {hand_2, _} ->
      g1 =
        String.graphemes(hand_1)
        |> Enum.sort(fn c1, c2 ->
          Map.get(@card_order, c1) > Map.get(@card_order, c2)
        end)

      f_1 = Enum.frequencies(g1)
      rank_1 = f_1 |> get_rank()

      g2 =
        String.graphemes(hand_2)
        |> Enum.sort(fn c1, c2 ->
          Map.get(@card_order, c1) > Map.get(@card_order, c2)
        end)

      f_2 = Enum.frequencies(g2)
      rank_2 = get_rank(f_2)

      if rank_1 == rank_2 do
        # m_1 =
        #   Enum.map(f_1, fn tuple -> tuple end)
        #   |> Enum.sort(fn {c1, f1}, {c2, f2} ->
        #     if(f1 == f2) do
        #       Map.get(@card_order, c1) > Map.get(@card_order, c2)
        #     else
        #       f1 > f2
        #     end
        #   end)
        #   |> Enum.map(fn {k, _} -> k end)
        #   |> IO.inspect(label: "m_1")

        # m_2 =
        #   Enum.map(f_2, fn tuple -> tuple end)
        #   |> Enum.sort(fn {c1, f1}, {c2, f2} ->
        #     if(f1 == f2) do
        #       Map.get(@card_order, c1) > Map.get(@card_order, c2)
        #     else
        #       f1 > f2
        #     end
        #   end)
        #   |> Enum.map(fn {k, _} -> k end)
        #   |> IO.inspect(label: "m_2")

        m_1 = String.graphemes(hand_1)
        m_2 = String.graphemes(hand_2)

        Enum.zip(m_1, m_2)
        |> Enum.reduce_while(true, fn {c_1, c_2}, _acc ->
          if Map.get(@card_order, c_1) == Map.get(@card_order, c_2) do
            {:cont, true}
          else
            {:halt, Map.get(@card_order, c_1) < Map.get(@card_order, c_2)}
          end
        end)

        # |> IO.inspect()
      else
        rank_1 > rank_2
      end
    end)
    |> tap(fn hands ->
      Enum.each(hands, fn {h, _} ->
        h
        |> String.graphemes()
        |> Enum.sort(fn c1, c2 ->
          Map.get(@card_order, c1) > Map.get(@card_order, c2)
        end)
        |> Enum.join()
      end)
    end)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {{_, bet}, idx}, acc ->
      acc + (idx + 1) * bet
    end)
  end

  defp get_rank(frequencies) do
    frequencies
    |> Map.values()
    |> Enum.sort(:desc)
    |> case do
      [5] -> 1
      [4, 1] -> 2
      [3, 2] -> 3
      [3, 1, 1] -> 4
      [2, 2, 1] -> 5
      [2, 1, 1, 1] -> 6
      [1, 1, 1, 1, 1] -> 7
    end
  end

  defp parse_data(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn line ->
      [hand, bet] = String.split(line, " ")
      {hand, String.to_integer(bet)}
    end)
  end
end
