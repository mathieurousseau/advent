defmodule AdventTest do
  use ExUnit.Case

  @year "2023"
  @day 24

  @days if @day != :all,
          do: [@day],
          else: 1..25

  doctest Advent

  for day <- @days do
    @tag timeout: :infinity
    test "run #{day}" do
      day = unquote(day)
      day = Integer.to_string(day) |> String.pad_leading(2, "0")
      do_run_test(day, "One")
      do_run_test(day, "Two")
    end
  end

  defp do_run_test(day, part) do
    {results, expected} = Advent.run("lib/#{@year}/inputs/test/", @year, day, part)
    assert {part, results} == {part, expected}

    if @day != :all do
      {real_output, _} = Advent.run("lib/#{@year}/inputs/real/", @year, day, part, false)
      IO.puts("Day#{day}, Part #{part} => #{real_output}")
    end
  end
end
