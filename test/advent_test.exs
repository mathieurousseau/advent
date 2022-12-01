defmodule AdventTest do
  use ExUnit.Case
  doctest Advent

  @expected [%{Elixir.Day01 => {71934, 211_447}}]

  test "run " do
    assert @expected == Advent.run()
  end
end
