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
end
