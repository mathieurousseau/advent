defmodule Advent do
  @days [
    One
  ]

  @spec run :: any
  def run do
    @days |> Enum.map(&%{&1 => &1.run()})
  end

  def print do
    run() |> IO.inspect()
  end
end
