defmodule Robozzle.Runner.Server do
  use GenServer

  alias Robozzle.Runner

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec run(GenServer.server, Runner.functions, Runner.ship, Runner.stage) :: outcome
          when outcome: {Runner.outcome, Runner.ship, Runner.stage}
  def run(server, fs, ship, stage) do
    GenServer.call(server, {:run, fs, ship, stage})
  end

  @spec load(GenServer.server, Runner.functions, Runner.ship, Runner.stage) :: :ok
  def load(server, fs, ship, stage) do
    GenServer.call(server, {:load, fs, ship, stage})
  end

  @spec step(GenServer.server) :: {Runner.outcome, Runner.ship, Runner.stage}
                                | {Runner.ship, Runner.stage}
                                | {:error, :no_scenario}
  def step(server) do
    GenServer.call(server, :step)
  end

  ## Callbacks

  def init(:ok) do
    {:ok, :run}
  end

  def handle_call({:run, fs, ship, stage}, _from, _state) do
    {:reply, Runner.run(fs, ship, stage), :run}
  end

  def handle_call({:load, fs, ship, stage}, _from, _state) do
    {:reply, :ok, {fs, ship, stage, Map.get(fs, :f1, []), 0}}
  end

  def handle_call(:step, _from, :run) do
    {:reply, {:error, :no_scenario}, :run}
  end
  def handle_call(:step, _from, {fs, ship, stage, stack, steps}) do
    case Runner.step(fs, ship, stage, stack, steps) do
      {ship, stage, stack, steps} ->
        {:reply, {ship, stage}, {fs, ship, stage, stack, steps}}
      {_, _, _} = over ->
        {:reply, over, :run}
    end
  end
end
