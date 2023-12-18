defmodule AdventTest do
  use ExUnit.Case

  @max_days 18

  @force_day ["18"]
  # @force_day nil

  @days @force_day ||
          1..@max_days
          |> Enum.map(fn day -> day |> Integer.to_string() |> String.pad_leading(2, "0") end)

  doctest Advent

  for day <- @days do
    @tag timeout: :infinity
    test "run #{day}" do
      day = unquote(day)
      do_run_test(day, "One")
      do_run_test(day, "Two")
    end
  end

  defp do_run_test(day, part) do
    {results, expected} = Advent.run("lib/inputs/test/", day, part)
    assert {part, results} == {part, expected}

    if @force_day do
      {real_output, _} = Advent.run("lib/inputs/real/", day, part)
      IO.puts("Day#{day}, Part #{part} => #{real_output}")
    end
  end
end
