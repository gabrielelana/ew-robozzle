defmodule Robozzle.Runner.ServerTest do
  use ExUnit.Case, async: true

  alias Robozzle.Runner
  import Robozzle.Parser

  setup do
    {:ok, runner} = Runner.Server.start_link
    {:ok, runner: runner}
  end

  test "run", %{runner: runner} do
    {ship, stage} = parse("beb.b.b*")
    functions = %{f1: [:forward, :forward, :forward]}

    assert {:complete, _, _} = Runner.Server.run(runner, functions, ship, stage)
  end

  test "interactive", %{runner: runner} do
    {ship, stage} = parse("beb.b.b*")
    functions = %{f1: [:forward, :forward, :forward]}

    assert :ok == Runner.Server.load(runner, functions, ship, stage)
    assert {_ship, _stage} = Runner.Server.step(runner)
    assert {_ship, _stage} = Runner.Server.step(runner)
    assert {:complete, _, _} = Runner.Server.step(runner)
  end

  test "interactive reset at begin", %{runner: runner} do
    {ship, stage} = parse("beb.b.b*")
    functions = %{f1: [:forward, :forward, :forward]}

    assert :ok == Runner.Server.load(runner, functions, ship, stage)
    assert {_ship, _stage} = Runner.Server.step(runner)
    assert :ok == Runner.Server.load(runner, functions, ship, stage)
    assert {_ship, _stage} = Runner.Server.step(runner)
    assert {_ship, _stage} = Runner.Server.step(runner)
    assert {:complete, _, _} = Runner.Server.step(runner)
  end

  test "interactive reset at run", %{runner: runner} do
    {ship, stage} = parse("beb.b.b*")
    functions = %{f1: [:forward, :forward, :forward]}

    assert :ok == Runner.Server.load(runner, functions, ship, stage)
    assert {_ship, _stage} = Runner.Server.step(runner)
    assert {:complete, _, _} = Runner.Server.run(runner, functions, ship, stage)
    assert {:error, :no_scenario} = Runner.Server.step(runner)
  end
end
