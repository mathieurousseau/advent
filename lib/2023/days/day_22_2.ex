defmodule Aoc2023.Day22Two do
  alias Aoc2023.Day22.Level
  alias Aoc2023.Day22.Meta
  alias Aoc2023.Day22.Brick
  @expected 7
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    meta =
      parse(input)
      |> Enum.sort(fn brick1, brick2 -> brick1.z < brick2.z end)
      |> Enum.reduce(%Meta{}, &stack_bricks(&1, &2))

    if map_size(meta.bricks) != length(String.split(input, "\n")) + 1,
      do: raise("missing bricks #{map_size(meta.bricks)}")

    height = meta.levels |> Map.keys() |> Enum.max()
    meta = %{meta | height: height}

    # print(meta)

    supporting_bricks = find_supporting_bricks(meta)

    count =
      start_count_falling_bricks(meta, supporting_bricks)
      |> Enum.map(fn {_k, v} ->
        MapSet.size(v)
      end)
      |> tap(&IO.puts("#{length(&1)}"))

    # length(count)
    Enum.sum(count)
    # IO.inspect(destroyable_bricks, limit: :infinity)

    # destroyable_bricks
  end

  defp start_count_falling_bricks(meta, supporting_bricks) do
    meta.bricks
    |> Map.keys()
    |> List.delete(-1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {brick_id, _idx}, acc ->
      # IO.puts("#{idx}-brick-#{brick_id}")
      falling = count_falling_bricks(meta, brick_id, supporting_bricks, MapSet.new([brick_id]))
      Map.put(acc, brick_id, MapSet.delete(falling, brick_id))
    end)
  end

  defp count_falling_bricks(meta, brick_id, supporting_bricks, falling) do
    supported_bricks = Map.get(supporting_bricks, brick_id)

    # IO.puts(
    #   "   falling - #{MapSet.size(falling)} // supported -> #{MapSet.size(supported_bricks)}"
    # )

    if supported_bricks do
      supported_bricks
      |> Enum.reduce(falling, fn supported_brick, falling ->
        # if MapSet.intersection() MapSet.new(supported_brick.supported_by)
        b = NaiveDateTime.utc_now()
        supported_by = Map.get(meta.supported_by, supported_brick)
        all = Enum.all?(supported_by, &MapSet.member?(falling, &1))

        a = NaiveDateTime.utc_now()
        # IO.puts("#{NaiveDateTime.diff(a, b)} - #{MapSet.size(supported_by)}")

        if all do
          falling = MapSet.put(falling, supported_brick)
          count_falling_bricks(meta, supported_brick, supporting_bricks, falling)
        else
          falling
        end
      end)
    else
      falling
    end
  end

  defp find_supporting_bricks(meta) do
    meta.height..0
    |> Enum.reduce(%{}, fn
      # level_id, {_, acc} ->
      #   level = Map.get(meta.levels, level_id, %Level{})

      #   acc = Enum.reduce(level.bricks, acc, fn brick, acc -> Map.put(acc, brick.id, 0) end)

      #   {level, acc}

      level_id, acc ->
        level = Map.get(meta.levels, level_id, %Level{})

        # acc = Enum.reduce(level.bricks, acc, fn brick, acc -> Map.put(acc, brick.id, 0) end)

        acc =
          Enum.reduce(level.bricks, acc, fn brick_id, acc ->
            # brick = Map.get(meta.bricks, brick_id)

            Map.get(meta.supported_by, brick_id, MapSet.new())
            |> Enum.map(&Map.get(meta.bricks, &1))
            |> Enum.reduce(acc, fn supporting_brick, acc ->
              # if brick.z == level_id do
              sup = Map.get(acc, supporting_brick.id, MapSet.new())
              Map.put(acc, supporting_brick.id, MapSet.put(sup, brick_id))
              # else
              # acc
              # end
            end)
          end)

        # destroyable = level.bricks |> Enum.filter(&can_destroy?(&1, level_id, level_above))
        # acc = add_list_to_set(destroyable, acc)
        acc
    end)
  end

  # defp can_destroy?(%Brick{ze: ze} = brick, level_id, level_above) when ze == level_id do
  #   supported_bricks =
  #     level_above.bricks
  #     |> Enum.filter(fn above_brick ->
  #       # IO.inspect(brick)
  #       # IO.inspect(above_brick)

  #       Enum.member?(above_brick.supported_by, brick)
  #       # above_brick.z == brick.ze
  #     end)

  #   supported_bricks
  #   |> Enum.all?(fn above_brick ->
  #     length(above_brick.supported_by) > 1
  #   end)
  # end

  # defp can_destroy?(brick, level_id, level_above), do: false

  # defp add_list_to_set(list, set), do: Enum.reduce(list, set, &MapSet.put(&2, &1.id))

  defp print(meta) do
    IO.puts("height: #{meta.height}")

    meta.height..0
    |> Enum.each(fn level_id ->
      level = Map.get(meta.levels, level_id)
      IO.puts("\n#level[#{level_id}]:")

      level.bricks
      |> Enum.each(fn brick_id ->
        brick = Map.get(meta.bricks, brick_id)

        IO.write(
          "  brick[x: #{inspect(brick.xr)} y: #{inspect(brick.yr)}, z: #{brick.z}..#{brick.ze}, id: #{brick.id}] by #{inspect(Map.get(meta.supported_by, brick.id, MapSet.new()) |> Enum.join(","))}\n"
        )
      end)
    end)

    meta
  end

  defp stack_bricks(brick, meta) do
    brick.z..0
    |> Enum.reduce_while(meta, fn current_z, meta ->
      with prev_level when not is_nil(prev_level) <- Map.get(meta.levels, current_z),
           [_ | _] = supported_by <- prev_level_supported_by(meta, prev_level, brick) do
        brick_z = current_z + 1

        brick = %{
          brick
          | z: brick_z,
            ze: current_z + brick.zl
        }

        supported_by = MapSet.new(supported_by)
        meta = %{meta | supported_by: Map.put(meta.supported_by, brick.id, supported_by)}
        meta = %{meta | bricks: Map.put(meta.bricks, brick.id, brick)}

        meta =
          brick_z..(brick_z + brick.zl - 1)
          |> Enum.reduce(meta, fn level_id, meta ->
            level = Map.get(meta.levels, level_id, %Level{})
            level = %{level | bricks: [brick.id | level.bricks]}
            levels = Map.put(meta.levels, level_id, level)
            %{meta | levels: levels}
          end)

        {:halt, meta}
      else
        _ -> {:cont, meta}
      end
    end)
  end

  defp prev_level_supported_by(meta, prev_level, brick) do
    prev_level.bricks |> Enum.filter(&prev_brick_blocking?(meta, &1, brick))
  end

  defp prev_brick_blocking?(meta, prev_brick_id, brick) do
    # # # IO.puts("#{prev_brick.id} - #{brick.id}")
    # # IO.inspect(prev_brick, label: "prev")
    # IO.inspect(brick, label: "brick")

    prev_brick = Map.get(meta.bricks, prev_brick_id)

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
        # xl: xe - x + 1,
        # yl: ye - y + 1,
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
