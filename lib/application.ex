defmodule Advent.Application do
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    Advent.print()

    Task.start(fn ->
      :timer.sleep(100)
    end)
  end
end
