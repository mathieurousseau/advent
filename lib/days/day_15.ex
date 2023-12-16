defmodule Day15 do
  alias Hex.API.Key
  @expected {"TBD", "TBD"}
  def run(input_1, input_2) do
    output_1 = first(input_1)

    output_2 = second(input_2)

    {{output_1, output_2}, @expected}
  end

  defp first(input) do
    input
    |> String.split(",")
    |> Enum.map(&convert(&1))
    |> Enum.reduce(%{}, &process_step(&1, &2))
    |> calculate()
    |> Enum.sum()
  end

  defp calculate(map) do
    map
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reduce([], fn hash, acc ->
      Map.get(map, hash)
      |> Map.drop([:idx])
      |> Enum.map(& &1)
      |> Enum.sort(fn {_, {idx_1, _}}, {_, {idx_2, _}} -> idx_1 < idx_2 end)
      |> Enum.map(fn {_, {_, length}} -> length end)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {lense_length, lense_idx}, acc ->
        [(hash + 1) * (lense_idx + 1) * lense_length | acc]
      end)
    end)
  end

  defp process_step({key, hash, "-", _value}, map) do
    lenses = Map.get(map, hash, %{})
    {_, lenses} = Map.pop(lenses, key)
    Map.put(map, hash, lenses)
  end

  defp process_step({key, hash, "=", value}, map) do
    lenses = Map.get(map, hash, %{})

    idx = Map.get(lenses, :idx, 0)
    lenses = Map.put(lenses, :idx, idx + 1)

    lenses =
      case Map.get(lenses, key) do
        nil ->
          Map.put(lenses, key, {idx + 1, String.to_integer(value)})

        {current_idx, _} ->
          Map.put(lenses, key, {current_idx, String.to_integer(value)})
      end

    Map.put(map, hash, lenses)
  end

  defp convert(instruction) do
    [[_, key, operation, value]] = Regex.scan(~r/(.*)(=|-)(.*)/, instruction)
    hash = hash(key)
    {key, hash, operation, value}
  end

  defp hash(label) do
    label
    |> String.to_charlist()
    |> Enum.reduce(0, fn c, acc ->
      c |> Kernel.+(acc) |> Kernel.*(17) |> rem(256)
    end)
  end

  defp second(_input) do
  end
end
