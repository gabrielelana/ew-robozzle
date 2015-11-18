defmodule Robozzle.Server do
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

  ## Callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:run, fs, ship, stage}, from, state) do
    spawn_link(fn ->
      :poolboy.transaction(:runners,
        fn(runner) ->
          GenServer.reply(from, Runner.Server.run(runner, fs, ship, stage))
        end)
    end)
    {:noreply, state}
  end
end
