defmodule Aoc2023.Day22One do
  defmodule Brick do
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
              yr: nil,
              supported_by: []
  end

  defmodule Level do
    defstruct bricks: []
  end

  defmodule Meta do
    @base_brick %Brick{
      id: -1,
      x: 0,
      y: 0,
      z: 0,
      xl: 10,
      yl: 10,
      zl: 1,
      xe: 10,
      ye: 10,
      ze: 1,
      xr: 0..10,
      yr: 0..10
    }
    @base_level %Level{bricks: [@base_brick]}
    defstruct levels: %{0 => @base_level}, height: -1
  end

  @expected 5
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    meta =
      parse(input)
      |> Enum.sort(fn brick1, brick2 -> brick1.z < brick2.z end)
      |> Enum.reduce(%Meta{}, &stack_bricks(&1, &2))

    # print(meta)

    # raise("stop")

    #

    height = meta.levels |> Map.keys() |> Enum.max()
    meta = %{meta | height: height}

    # print(meta)
    # raise("mathieu")

    destroyable_bricks = find_bricks(meta)
    # IO.inspect(destroyable_bricks, limit: :infinity)

    destroyable_bricks |> MapSet.size()
  end

  defp find_bricks(meta) do
    {_, acc} =
      meta.height..0
      |> Enum.reduce({nil, MapSet.new()}, fn
        level_id, {nil = _level_Abo, acc} ->
          level = Map.get(meta.levels, level_id, %Level{})

          acc = add_list_to_set(level.bricks, acc)

          {level, acc}

        level_id, {level_above, acc} ->
          level = Map.get(meta.levels, level_id, %Level{})
          destroyable = level.bricks |> Enum.filter(&can_destroy?(&1, level_id, level_above))
          acc = add_list_to_set(destroyable, acc)
          {level, acc}
      end)

    acc
  end

  defp can_destroy?(%Brick{ze: ze} = brick, level_id, level_above) when ze == level_id do
    supported_bricks =
      level_above.bricks
      |> Enum.filter(fn above_brick ->
        # IO.inspect(brick)
        # IO.inspect(above_brick)

        Enum.member?(above_brick.supported_by, brick)
        # above_brick.z == brick.ze
      end)

    supported_bricks
    |> Enum.all?(fn above_brick ->
      length(above_brick.supported_by) > 1
    end)
  end

  defp can_destroy?(_brick, _level_id, _level_above), do: false

  defp add_list_to_set(list, set), do: Enum.reduce(list, set, &MapSet.put(&2, &1.id))

  defp print(meta) do
    IO.puts("height: #{meta.height}")

    meta.height..0
    |> Enum.each(fn level_id ->
      level = Map.get(meta.levels, level_id)
      IO.puts("\n#level[#{level_id}]:")

      level.bricks
      |> Enum.each(fn brick ->
        IO.write(
          "  brick[x: #{inspect(brick.xr)} y: #{inspect(brick.yr)}, z: #{brick.z}..#{brick.ze}, id: #{brick.id}] by #{inspect(brick.supported_by |> Enum.map(& &1.id) |> Enum.join(","))}\n"
        )
      end)
    end)

    meta
  end

  defp stack_bricks(brick, meta) do
    brick.z..0
    |> Enum.reduce_while(meta, fn current_z, meta ->
      with prev_level when not is_nil(prev_level) <- Map.get(meta.levels, current_z),
           [_ | _] = supported_by <- prev_level_supported_by(prev_level, brick) do
        brick_z = current_z + 1

        brick = %{
          brick
          | z: brick_z,
            ze: current_z + brick.zl,
            supported_by: supported_by
        }

        meta =
          brick_z..(brick_z + brick.zl - 1)
          |> Enum.reduce(meta, fn level_id, meta ->
            level = Map.get(meta.levels, level_id, %Level{})
            level = %{level | bricks: [brick | level.bricks]}
            levels = Map.put(meta.levels, level_id, level)
            %{meta | levels: levels}
          end)

        {:halt, meta}
      else
        _ -> {:cont, meta}
      end
    end)
  end

  defp prev_level_supported_by(prev_level, brick) do
    prev_level.bricks |> Enum.filter(&prev_brick_blocking?(&1, brick))
  end

  defp prev_brick_blocking?(prev_brick, brick) do
    # # # IO.puts("#{prev_brick.id} - #{brick.id}")
    # # IO.inspect(prev_brick, label: "prev")
    # IO.inspect(brick, label: "brick")

    with false <- Range.disjoint?(prev_brick.xr, brick.xr),
         false <- Range.disjoint?(prev_brick.yr, brick.yr),
         x_intersection <- max(brick.x, prev_brick.x)..min(brick.xe, prev_brick.xe),
         y_intersection <- max(brick.y, prev_brick.y)..min(brick.ye, prev_brick.ye),
         x_size when x_size > 0 <- x_intersection.last - x_intersection.first,
         y_size when y_size > 0 <- y_intersection.last - y_intersection.first do
      true
    else
      _ -> false
    end
  end

  # 1..2
  # 2..3

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.map(fn {line, idx} ->
      [matches] = Regex.scan(~r/(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/, line)

      [x, y, z, xe, ye, ze] = matches |> tl() |> Enum.map(&String.to_integer(&1))

      %Brick{
        id: idx,
        x: x,
        y: y,
        z: z,
        xl: xe - x + 1,
        yl: ye - y + 1,
        zl: ze - z + 1,
        xe: xe + 1,
        ye: ye + 1,
        ze: ze + 1,
        xr: x..(xe + 1),
        yr: y..(ye + 1)
        # zr: z..(ze + 1)
      }
    end)
  end
end
