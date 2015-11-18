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

  test "solve" do
    {ship, stage} = parse("beb.b.b*")

    assert {:solution, solution} = Robozzle.solve(%{f1: 3}, ship, stage)
    assert {:complete, _, _} = Robozzle.Runner.run(solution, ship, stage)
  end

  test "solve hard" do
    {ship, stage} = parse("""
                          ..........b*b*
                          ........b*b*..
                          ......b*b*....
                          ....b*b*......
                          ..b*b*........
                          beb*..........
                          """)


    assert {:solution, solution} = Robozzle.solve(%{f1: 5}, ship, stage)
    assert {:complete, _, _} = Robozzle.Runner.run(solution, ship, stage)
  end
end
