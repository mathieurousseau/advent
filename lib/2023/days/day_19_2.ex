defmodule Aoc2023.Day19Two do
  @expected 167_409_079_868_000
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {workflows, _parts} = parse(input)

    range = [1, 4000]
    part = %{x: range, m: range, a: range, s: range}

    apply_workflow(part, workflows)
    |> Enum.map(fn %{x: [x1, x2], m: [m1, m2], a: [a1, a2], s: [s1, s2]} ->
      (x2 - x1 + 1) * (m2 - m1 + 1) * (a2 - a1 + 1) * (s2 - s1 + 1)
    end)
    |> Enum.sum()
  end

  defp apply_workflow(part, workflows, wf_key \\ "in")

  defp apply_workflow(part, _workflows, "A"), do: [part]

  defp apply_workflow(_part, _workflows, "R"), do: []

  defp apply_workflow(part, workflows, wf_key) do
    wf_logics = Map.get(workflows, wf_key)
    if is_nil(wf_logics), do: raise("no good")

    execute_logics(part, workflows, wf_logics)
  end

  defp execute_logics(part, _workflows, ["A"]), do: [part]

  defp execute_logics(_part, _workflows, ["R"]), do: []

  defp execute_logics(part, workflows, [logic | rest]) do
    case logic do
      {cat, "<", value, target} ->
        [first, last] = Map.get(part, cat)

        cond do
          value > first and value <= last ->
            part_first = Map.put(part, cat, [first, value - 1])
            part_second = Map.put(part, cat, [value, last])

            apply_workflow(part_first, workflows, target) ++
              execute_logics(part_second, workflows, rest)

          value < first ->
            []

          value >= first ->
            apply_workflow(part, workflows, target)
        end

      {cat, ">", value, target} ->
        [first, last] = Map.get(part, cat)

        cond do
          value >= first and value < last ->
            part_first = Map.put(part, cat, [first, value])
            part_second = Map.put(part, cat, [value + 1, last])

            execute_logics(part_first, workflows, rest) ++
              apply_workflow(part_second, workflows, target)

          value >= first ->
            apply_workflow(part, workflows, target)

          value < first ->
            []
        end

      target ->
        apply_workflow(part, workflows, target)
    end
  end

  defp parse(input) do
    [workflows, parts] = String.split(input, "\n\n")

    workflows =
      workflows
      |> String.split("\n")
      |> Enum.map(&parse_workflows(&1))
      |> Enum.reduce(%{}, fn {wf_key, logics}, acc -> Map.put(acc, wf_key, logics) end)

    parts = parse_parts(parts)
    {workflows, parts}
  end

  defp parse_parts(parts) do
    String.split(parts, "\n")
    |> Enum.map(fn part ->
      [[_, x, m, a, s]] = Regex.scan(~r/{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}/u, part)

      %{
        x: String.to_integer(x),
        m: String.to_integer(m),
        a: String.to_integer(a),
        s: String.to_integer(s)
      }
    end)
  end

  defp parse_workflows(workflow) do
    [[_, wf_key, logics]] = Regex.scan(~r/(.*){(.*)}/u, workflow)

    logics =
      String.split(logics, ",")
      |> Enum.map(fn logic ->
        if(String.contains?(logic, ":")) do
          [[_, category, comp, number, target]] = Regex.scan(~r/(.*)(<|>)(\d+):(.*)/u, logic)
          {String.to_atom(category), comp, String.to_integer(number), target}
        else
          logic
        end
      end)

    {wf_key, logics}
  end
end
