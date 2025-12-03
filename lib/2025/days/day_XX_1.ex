defmodule Aoc2025.DayXXOne do
  @expected :success
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parse(input)
  end

  defp parse(input) do
    IO.inspect(input)
    :success
  end
end
