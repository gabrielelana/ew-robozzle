defmodule Robozzle.Server do
  use GenServer

  alias Robozzle.Solver
  alias Robozzle.Runner

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec run(GenServer.server, Runner.functions, Runner.ship, Runner.stage) :: outcome
          when outcome: :busy | {Runner.outcome, Runner.ship, Runner.stage}
  def run(server, fs, ship, stage) do
    GenServer.call(server, {:run, fs, ship, stage})
  end

  @spec solve(GenServer.server, Solver.constraints, Runner.ship, Runner.stage) :: outcome
          when outcome: :busy | :timeout | {:solution, Runner.functions}
  def solve(server, sc, ship, stage) do
    GenServer.call(server, {:solve, sc, ship, stage}, :infinity)
  end

  @spec solved?(GenServer.server, reference) :: boolean
  def solved?(server, scenario) do
    GenServer.call(server, {:solved?, scenario})
  end

  @spec report_solution(GenServer.server, reference, Runner.functions) :: :ok
  def report_solution(server, scenario, solution) do
    GenServer.cast(server, {:solution, scenario, solution})
  end

  ## Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:run, _, _, _}, _, %{solving: _} = state), do: {:reply, :busy, state}
  def handle_call({:run, fs, ship, stage}, from, state) do
    spawn_link(fn ->
      :poolboy.transaction(:runners,
        fn(runner) ->
          GenServer.reply(from, Runner.Server.run(runner, fs, ship, stage))
        end)
    end)
    {:noreply, state}
  end

  def handle_call({:solve, _, _, _}, _, %{solving: _} = state), do: {:reply, :busy, state}
  def handle_call({:solve, sc, ship, stage}, from, _) do
    scenario = make_ref
    Process.send_after(self, :timeout, 1_000 * 60 * 5)
    Robozzle.Drone.explore(scenario, [], sc, ship, stage, self)
    {:noreply, %{solving: scenario, from: from}}
  end

  def handle_call({:solved?, scenario}, _, %{solving: scenario} = state) do
    {:reply, false, state}
  end
  def handle_call({:solved?, _}, _, state) do
    {:reply, true, state}
  end

  def handle_cast({:solution, scenario, solution}, %{solving: scenario, from: from}) do
    GenServer.reply(from, {:solution, solution})
    {:noreply, %{}}
  end
  def handle_cast({:solution, _, _}, state) do
    {:noreply, state}
  end

  def handle_info(:timeout, %{solving: _, from: from}) do
    GenServer.reply(from, :timeout)
    {:noreply, %{}}
  end
end
