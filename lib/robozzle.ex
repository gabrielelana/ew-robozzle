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
      {:size, 4},
      {:max_overflow, 1}
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

  @spec run(Runner.functions, Runner.ship, Runner.stage) :: outcome
          when outcome: {Runner.outcome, Runner.ship, Runner.stage}
  def run(fs, ship, stage) do
    Robozzle.Server.run(:robozzle, fs, ship, stage)
  end
end
