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
    # IO.inspect(solution)
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
    # IO.inspect(solution)
  end

  # @tag timeout: 60_000_000
  # test "solve very hard" do
  #   # http://www.robozzle.com/js/play.aspx?puzzle=644
  #   # SOLUTION:
  #   # f1: [{:left, :green}, :forward, {:right, :red}, {{:call, :f2}, :red}, {:call, :f1}]
  #   # f2: [{:right, :green}, :forward, {:call, :f2}]
  #   {ship, stage} = parse(
  #     """
  #     ....g.b.b.b.b.b.b.g.
  #     ....b.............b.
  #     ....b.............b.
  #     ....b...beb.b.b.b.g.
  #     ....b...............
  #     b*..g.r.g...........
  #     b.....b.............
  #     g.b.b.g.............
  #     """)

  #   assert {:solution, solution} = Robozzle.solve(%{f1: 5, f2: 4}, ship, stage)
  #   assert {:complete, _, _} = Robozzle.Runner.run(solution, ship, stage)
  #   IO.inspect(solution)
  # end
end
