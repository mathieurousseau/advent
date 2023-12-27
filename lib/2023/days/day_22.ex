defmodule Aoc2023.Day22.Brick do
  defstruct id: nil,
            x: nil,
            y: nil,
            z: nil,
            xl: nil,
            yl: nil,
            zl: nil,
            xe: nil,
            ye: nil,
            ze: nil,
            xr: nil,
            yr: nil
end

defmodule Aoc2023.Day22.Level do
  alias Aoc2023.Day22.Brick

  defstruct bricks: []
end

defmodule Aoc2023.Day22.Meta do
  alias Aoc2023.Day22.Brick
  alias Aoc2023.Day22.Level

  @base_brick %Brick{
    id: -1,
    x: 0,
    y: 0,
    z: 0,
    # xl: 10,
    # yl: 10,
    zl: 1,
    xe: 10,
    ye: 10,
    ze: 1,
    xr: 0..10,
    yr: 0..10
  }
  @base_level %Level{bricks: [-1]}
  defstruct levels: %{0 => @base_level},
            height: -1,
            supporting_bricks: %{},
            supported_by: %{},
            bricks: %{-1 => @base_brick}
end
