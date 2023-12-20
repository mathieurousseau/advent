defmodule Aoc2023.Day20Two do
  @expected 247_702_167_614_647
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {modules, inputs} = parse(input)

    queue = :queue.new()

    result =
      1..100_000_000_000_000_000
      |> Enum.reduce_while({queue, modules, inputs}, fn idx, {queue, modules, inputs} ->
        queue = enqueue(queue, nil, Map.get(modules, :broadcaster), :low)

        ctx = process_queue({queue, modules, inputs}, idx)

        keys =
          [{"dx", "mp"}, {"ck", "qt"}, {"cs", "qb"}, {"jh", "ng"}]
          |> Enum.map(fn {from, to} -> "cycle_#{from}_#{to}" end)

        cycles = Map.take(inputs, keys)

        if map_size(cycles) == 4 do
          inspect(cycles)
          {:halt, cycles}
        else
          {:cont, ctx}
        end
      end)

    Map.values(result) |> Aoc.lcm()
  end

  defp process_queue({queue, modules, inputs}, idx) do
    case :queue.out(queue) do
      {:empty, queue} ->
        {queue, modules, inputs}

      {{:value, {from, to, signal}}, queue} ->
        module = Map.get(modules, to)

        {module, signal, next_tos, inputs} = check_cycle(from, to, module, signal, inputs, idx)

        modules =
          if module do
            Map.put(modules, to, module)
          else
            modules
          end

        queue = enqueue(queue, to, next_tos, signal)

        process_queue({queue, modules, inputs}, idx)
    end
  end

  defp check_cycle(from, to, module, :low, inputs, idx)
       when (from == "dx" and to == "mp") or
              (from == "ck" and to == "qt") or
              (from == "cs" and to == "qb") or
              (from == "jh" and to == "ng") do
    # IO.puts("#{from} -> #{to} : low - #{idx}")

    inputs =
      if Map.get(inputs, "cycle_#{from}_#{to}") |> is_nil() do
        Map.put(inputs, "cycle_#{from}_#{to}", idx)
      end

    execute_module(from, to, module, :low, inputs)
  end

  defp check_cycle(from, to, module, signal, inputs, _idx) do
    execute_module(from, to, module, signal, inputs)
  end

  defp execute_module(_from, _to, nil, _, inputs), do: {nil, nil, [], inputs}

  defp execute_module(_from, _to, {"%", _tos, _status} = module, :high, inputs),
    do: {module, nil, [], inputs}

  defp execute_module(_from, _to, {"%", tos, status}, :low, inputs) do
    case status do
      :off ->
        {{"%", tos, :on}, :high, tos, inputs}

      :on ->
        {{"%", tos, :off}, :low, tos, inputs}
    end
  end

  defp execute_module(from, to, {"&", tos, _}, signal, inputs) do
    module_inputs = Map.get(inputs, to)
    module_inputs = Map.put(module_inputs, from, signal)
    inputs = Map.put(inputs, to, module_inputs)

    if Map.values(module_inputs) |> Enum.all?(&(&1 == :high)) do
      {{"&", tos, nil}, :low, tos, inputs}
    else
      {{"&", tos, nil}, :high, tos, inputs}
    end
  end

  defp enqueue(queue, from, tos, signal) do
    Enum.reduce(tos, queue, fn to, queue -> :queue.in({from, to, signal}, queue) end)
  end

  defp parse(input) do
    String.split(input, "\n")
    |> Enum.reduce({%{}, %{}}, fn module, {modules, inputs} ->
      [from, to] = String.split(module, " -> ", trim: true)

      tos = String.split(to, ", ", trim: true)

      case from do
        "broadcaster" ->
          {Map.put(modules, :broadcaster, tos), inputs}

        "%" <> mod_key ->
          {Map.put(modules, mod_key, {"%", tos, :off}), add_inputs(mod_key, tos, inputs)}

        "&" <> mod_key ->
          {Map.put(modules, mod_key, {"&", tos, nil}), add_inputs(mod_key, tos, inputs)}

        no_good ->
          raise(no_good)
      end
    end)
  end

  defp add_inputs(from, tos, inputs) do
    Enum.reduce(tos, inputs, fn to, inputs ->
      {_, inputs} =
        Map.get_and_update(inputs, to, fn
          nil -> {nil, %{from => :low}}
          module_inputs -> {module_inputs, Map.put(module_inputs, from, :low)}
        end)

      inputs
    end)
  end
end
