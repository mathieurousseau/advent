defmodule Day07Two do
  @expected 5905
  def run(input) do
    {do_run(input), @expected}
  end

  @card_order Stream.zip(~w(A K Q T 9 8 7 6 5 4 3 2 J X), 14..0) |> Map.new()
  defp do_run(input) do
    list = parse_data(input)

    Enum.sort(list, fn {hand_1, _, original_hand_1}, {hand_2, _, original_hand_2} ->
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

        m_1 = String.graphemes(original_hand_1)
        m_2 = String.graphemes(original_hand_2)

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
      Enum.each(hands, fn {h, _, _} ->
        h
        |> String.graphemes()
        |> Enum.sort(fn c1, c2 ->
          Map.get(@card_order, c1) > Map.get(@card_order, c2)
        end)
        |> Enum.join()

        # |> IO.inspect(label: "mathieu")
      end)
    end)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {{_, bet, _}, idx}, acc ->
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
      {magic_hand(hand), String.to_integer(bet), hand}
    end)
  end

  defp magic_hand(hand) do
    if String.contains?(hand, "J") do
      do_magic_hand(hand)
    else
      hand
    end
  end

  defp do_magic_hand(hand) do
    f =
      String.graphemes(hand)
      |> Enum.frequencies()

    f_tuples_no_j =
      f
      |> Map.drop(["J"])
      |> Enum.map(& &1)
      |> Enum.sort(fn {_c1, f1}, {_c2, f2} ->
        f1 > f2
      end)

    keys = Map.keys(f) |> List.delete("J") |> sort_by()

    clean_hand = String.replace(hand, "J", "")

    case get_rank(f) do
      1 ->
        "AAAAA"

      2 ->
        keys |> hd |> String.duplicate(5)

      3 ->
        case Map.get(f, "J", 0) do
          2 -> keys |> hd |> String.duplicate(5)
          3 -> keys |> hd |> String.duplicate(5)
        end

      4 ->
        case Map.get(f, "J", 0) do
          1 ->
            [{c, 3}, _] = f_tuples_no_j
            c <> clean_hand

          3 ->
            [{c1, 1}, {c2, 1}] = f_tuples_no_j
            (max_c(c1, c2) |> String.duplicate(3)) <> clean_hand
        end

      # 2, 2, 1
      5 ->
        case Map.get(f, "J", 0) do
          1 ->
            [{c1, 2}, {c2, 2}] = f_tuples_no_j
            max_c(c1, c2) <> clean_hand

          2 ->
            [{c, 2}, {_, 1}] = f_tuples_no_j
            String.duplicate(c, 2) <> clean_hand
        end

      # 2, 1, 1, 1
      6 ->
        case Map.get(f, "J", 0) do
          1 ->
            [{c, 2} | _] = f_tuples_no_j
            c <> clean_hand

          2 ->
            [{c1, 1}, {c2, 1}, {c3, 1}] = f_tuples_no_j
            (max_c(c1, c2) |> max_c(c3) |> String.duplicate(2)) <> clean_hand
        end

      7 ->
        [{c1, 1}, {c2, 1}, {c3, 1}, {c4, 1}] = f_tuples_no_j
        (max_c(c1, c2) |> max_c(c3) |> max(c4)) <> clean_hand
    end

    # |> Enum.map(& &1)
    # |> Enum.sort(fn {c1, f1}, {c2, f2} ->
    #   f1 > f2
    # end)
    # |> Enum.reduce("", fn {c, _}, magic_hand ->
    #   if("J")
    # end)
  end

  defp max_c(c1, c2) do
    if Map.get(@card_order, c1) > Map.get(@card_order, c2) do
      c1
    else
      c2
    end
  end

  defp sort_by(list) do
    Enum.sort(list, fn c1, c2 ->
      Map.get(@card_order, c1) > Map.get(@card_order, c2)
    end)
  end
end
