defmodule Day01 do
  def run(input) do
    first_input = input
    first_output = first(first_input)

    second_input = input
    second_output = second(second_input)

    {first_output, second_output}
  end

  defp first(_first_input) do
    nil
  end

  defp second(_second_input) do
    nil
  end
end
