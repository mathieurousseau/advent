defmodule Aoc2025.Day04One do
  @expected :success
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    parse(input)
  end

  defp parse(_input) do
    :success
  end
end
