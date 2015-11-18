defmodule Robozzle do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    poolboy_name = :runners
    poolboy_config = [
      {:name, {:local, poolboy_name}},
      {:worker_module, Robozzle.Runner.Server},
      {:size, 12},
      {:strategy, :fifo},
      {:max_overflow, 1},
    ]

    children = [
      # Define workers and child supervisors to be supervised
      worker(Robozzle.Server, [[name: :robozzle]]),
      :poolboy.child_spec(poolboy_name, poolboy_config, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Robozzle.Supervisor]
    Supervisor.start_link(children, opts)
  end

  alias Robozzle.Runner
  alias Robozzle.Server

  @spec run(Runner.functions, Runner.ship, Runner.stage) :: outcome
          when outcome: :busy | {Runner.outcome, Runner.ship, Runner.stage}
  def run(fs, ship, stage) do
    Server.run(:robozzle, fs, ship, stage)
  end

  @spec solve(Server.solution_constraints, Runner.ship, Runner.stage) :: outcome
          when outcome: :busy | :timetout | {:solution, Runner.functions}
  def solve(sc, ship, stage) do
    Server.solve(:robozzle, sc, ship, stage)
  end
end
