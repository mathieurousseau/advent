defmodule AdventTest do
  use ExUnit.Case
  doctest Advent

  test "run " do
    {results, expected} = Advent.run("lib/inputs/test/")
    assert results == expected
  end
end
