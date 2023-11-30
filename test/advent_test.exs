defmodule AdventTest do
  use ExUnit.Case
  doctest Advent

  @expected %{
    Day01 => {nil, nil}
    # Day02 => {15, 12},
    # Day03 => {157, 70},
    # Day04 => {2, 4},
    # Day05 => {"CMZ", "MCD"},
    # Day06 => {[7, 5, 6, 10, 11], [19, 23, 23, 29, 26]},
    # Day07 => {95437, 24_933_642},
    # Day08 => {21, 0}
  }

  test "run " do
    assert @expected == Advent.run("lib/inputs/test/")
  end
end
