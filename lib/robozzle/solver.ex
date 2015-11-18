defmodule Robozzle.Solver do

  alias Robozzle.Runner

  @type solution :: [Runner.command | :nop]
  @type constraints :: %{Runner.function_name => commands::pos_integer}
  @type functions :: Runner.functions

  @spec functions_from(solution, constraints) :: functions
  def functions_from(solution, constraints) do
    constraints
    |> Enum.reduce({%{}, 0}, &functions_reduce(&1, &2, solution))
    |> elem(0)
  end

  defp functions_reduce({name, length}, {functions, start}, solution) do
    commands = Enum.slice(solution, start, length)
               |> Enum.reverse
               |> Enum.drop_while(&(&1 === :nop))
               |> Enum.reverse
    functions = Map.put(functions, name, commands)
    start = start + length
    {functions, start}
  end

  @spec next_solutions(solution, constraints, :full | :basic) :: [solution]
  def next_solutions(solution, constraints, strategy \\ :full) do
    commands_given(constraints, strategy)
    |> Enum.map(&Enum.concat(solution, [&1]))
    |> Enum.filter(&good_solution(&1, constraints))
    |> Enum.shuffle
  end

  defp good_solution(solution, constraints) do
    length_within_limits(solution, constraints) &&
    no_nop_between_commands_in_functions(solution, constraints)
  end

  defp length_within_limits(solution, constraints) do
    length(solution) <= (constraints |> Map.values |> Enum.sum)
  end

  defp no_nop_between_commands_in_functions(solution, constraints) do
    functions_from(solution, constraints) |> Enum.all?(&good_function/1)
  end

  defp good_function({_, commands}) do
    Enum.count(commands, &(&1 === :nop)) === 0
  end

  defp commands_given(constraints, :basic) do
    basic_commands_given(constraints)
  end
  defp commands_given(constraints, :condition) do
    basic_commands_given(constraints)
    |> Enum.reduce([], fn(c, cs) -> Enum.concat(cs, conditional_commands_of(c)) end)
  end
  defp commands_given(constraints, :full) do
    basic_commands_given(constraints)
    |> Enum.concat(paint_commands)
    |> Enum.reduce([], fn(c, cs) -> Enum.concat(cs, conditional_commands_of(c)) end)
  end

  defp paint_commands,
    do: [{:paint, :green}, {:paint, :blue}, {:paint, :red}]
  defp basic_commands_given(constraints),
    do: [:nop, :forward, :right, :left]
        |> Enum.concat(call_commands_for(constraints))
  defp call_commands_for(constraints),
    do: constraints |> Map.keys |> Enum.map(&{:call, &1})

  defp conditional_commands_of(:nop), do: [:nop]
  defp conditional_commands_of(c), do: [c, {c, :green}, {c, :blue}, {c, :red}]
end
