defmodule AdventTest do
  use ExUnit.Case
  doctest Advent

  @expected %{Day01 => {71934, 211_447}, Day02 => {15, 12}, Day03 => {157, 70}}

  test "run " do
    assert @expected == Advent.run("lib/inputs/test/")
  end
end
