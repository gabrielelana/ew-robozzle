defmodule Robozzle.Drone do

  alias Robozzle.Solver
  alias Robozzle.Runner
  alias Robozzle.Server

  @spec explore(reference, Solver.solution, Solver.constraints,
                Runner.ship, Runner.stage, pid) :: :ok
  def explore(scenario, solution, constraints, ship, stage, server) do
    spawn(fn -> do_explore(scenario, solution, constraints, ship, stage, server) end)
    :ok
  end

  defp do_explore(scenario, solution, constraints, ship, stage, server) do
    if Server.solved?(server, scenario) do
      :ok
    else
      run(solution, constraints, ship, stage)
      |> handle_outcome(scenario, solution, constraints, ship, stage, server)
    end
  end

  defp run(solution, constraints, ship, stage) do
    :poolboy.transaction(
      :runners,
      &Runner.Server.run(&1, Solver.functions_from(solution, constraints), ship, stage),
      60_000)
  end

  defp handle_outcome(outcome, scenario, solution, constraints, ship, stage, server) do
    case outcome do
      {:complete, _, _} ->
        Server.report_solution(server, scenario, Solver.functions_from(solution, constraints))
      {:out_of_stage, _, _} ->
        :ok
      {_, _, _} ->
        Solver.next_solutions(solution, constraints, :basic)
        |> Enum.map(&explore(scenario, &1, constraints, ship, stage, server))
    end
  end
end
