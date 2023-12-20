defmodule Aoc2023.Day20One do
  @expected 11_687_500
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {modules, inputs} = parse(input)

    queue = :queue.new()

    {_, _modules, _inputs, count} =
      1..1000
      |> Enum.reduce({queue, modules, inputs, {0, 0}}, fn _,
                                                          {queue, modules, inputs,
                                                           {count_low, count_high}} ->
        queue = enqueue(queue, nil, Map.get(modules, :broadcaster), :low)
        process_queue({queue, modules, inputs, {count_low + 1, count_high}})
      end)

    {low, high} = count
    low * high
  end

  defp process_queue({queue, modules, inputs, {count_low, count_high} = count}) do
    case :queue.out(queue) do
      {:empty, queue} ->
        {queue, modules, inputs, count}

      {{:value, {from, to, signal}}, queue} ->
        count =
          case signal do
            :low -> {count_low + 1, count_high}
            :high -> {count_low, count_high + 1}
          end

        # execute_module()
        module = Map.get(modules, to)
        {module, signal, next_tos, inputs} = execute_module(from, to, module, signal, inputs)

        modules =
          if module do
            Map.put(modules, to, module)
          else
            modules
          end

        queue = enqueue(queue, to, next_tos, signal)

        process_queue({queue, modules, inputs, count})
    end
  end

  defp execute_module(_from, _to, nil, _, inputs),
    do: {nil, nil, [], inputs}

  defp execute_module(_from, _to, {"%", _tos, _} = module, :high, inputs),
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
