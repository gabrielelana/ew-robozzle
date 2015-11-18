defmodule RobozzleTest do
  use ExUnit.Case
  doctest Robozzle

  import Robozzle.Parser

  setup do
    Logger.remove_backend(:console)
    Application.stop(:robozzle)
    :ok = Application.start(:robozzle)
    Logger.add_backend(:console, flush: true)
    :ok
  end

  test "run" do
    {ship, stage} = parse("beb.b.b*")
    functions = %{f1: [:forward, :forward, :forward]}

    assert {:complete, _, _} = Robozzle.run(functions, ship, stage)
  end
end
