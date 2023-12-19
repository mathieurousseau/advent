defmodule Aoc2023.Day19One do
  @expected 19114
  def run(input) do
    {do_run(input), @expected}
  end

  defp do_run(input) do
    {workflows, parts} = parse(input)

    Enum.map(parts, &apply_workflow(&1, workflows))
    |> Enum.reject(&is_nil(&1))
    |> Enum.map(&Map.values(&1))
    |> List.flatten()
    |> Enum.sum()
  end

  defp apply_workflow(part, workflows, wf_key \\ "in") do
    wf_logics = Map.get(workflows, wf_key)
    if is_nil(wf_logics), do: raise("no good")

    execute_logics(part, wf_logics)
    |> case do
      "R" -> nil
      "A" -> part
      new_wf_key -> apply_workflow(part, workflows, new_wf_key)
    end
  end

  defp execute_logics(_part, [last]), do: last

  defp execute_logics(part, [logic | rest]) do
    case logic do
      {cat, "<", value, target} ->
        if Map.get(part, cat) < value, do: target, else: execute_logics(part, rest)

      {cat, ">", value, target} ->
        if Map.get(part, cat) > value, do: target, else: execute_logics(part, rest)

      target ->
        target
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
