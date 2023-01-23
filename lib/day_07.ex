defmodule Day07 do
  @spec run(binary) :: {any, any}
  def run(input) do
    {part1(input), part2(input)}
  end

  defp part1(input) do
    input
    |> String.split("\n")
    |> Enum.reduce(%{all: %{}, wd: []}, &process(&1, &2))
    |> Map.get(:all)
    |> Enum.reduce(0, fn {_k, v}, acc ->
      if v <= 100_000 do
        acc + v
      else
        acc
      end
    end)
  end

  defp process("$ cd ..", %{wd: wd} = data) do
    %{data | wd: tl(wd)}
  end

  defp process("$ cd " <> dir, %{all: all, wd: wd} = _data) do
    wd = [dir | wd]
    all = Map.put(all, wd, Map.get(all, wd, 0))

    %{all: all, wd: wd}
  end

  defp process("$ ls" <> _ls, data) do
    data
  end

  defp process("dir " <> _dir, data) do
    data
  end

  defp process(file, %{all: all, wd: wd} = data) do
    [file_size, _name] = file |> String.split(" ")
    file_size = String.to_integer(file_size)
    all = add_to_folders(all, wd, file_size)

    %{data | all: all}
  end

  defp add_to_folders(folders, [_h | t] = wd, file_size) do
    new_folder_size = Map.get(folders, wd) + file_size
    Map.put(folders, wd, new_folder_size) |> add_to_folders(t, file_size)
  end

  defp add_to_folders(folders, _, _) do
    folders
  end

  defp part2(input) do
    folders =
      input
      |> String.split("\n")
      |> Enum.reduce(%{all: %{}, wd: []}, &process(&1, &2))
      |> Map.get(:all)

    needed = 30_000_000 - (70_000_000 - folders[["/"]])

    folders |> Map.values() |> Enum.sort() |> Enum.find(&(&1 >= needed))
  end
end
