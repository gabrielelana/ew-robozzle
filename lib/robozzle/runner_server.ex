defmodule Robozzle.Runner.Server do
  use GenServer

  alias Robozzle.Runner

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec run(pid, Runner.functions, Runner.ship, Runner.stage) :: outcome
          when outcome: {Runner.outcome, Runner.ship, Runner.stage}
  def run(pid, fs, ship, stage) do
    GenServer.call(pid, {:run, fs, ship, stage})
  end

  ## Callbacks

  def init(:ok) do
    {:ok, :run}
  end

  def handle_call({:run, fs, ship, stage}, _from, :run) do
    {:reply, Runner.run(fs, ship, stage), :run}
  end
end
