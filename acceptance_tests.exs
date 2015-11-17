defmodule Robozzle.AcceptanceTest do
  use ExUnit.Case, async: true
  import Robozzle

  test "incomplete" do
    assert_scenario :incomplete, "beb.b*", f1: []
    assert_scenario :incomplete, "beb.b*", f1: [:forward]
  end

  test "complete" do
    assert_scenario :complete, "beb.b*", f1: [:forward, :forward]
    assert_scenario :complete, """
                               b.b.b.bsb.b.b.
                               b.b.b.b.b.b.b.
                               b.b.b.b.b.b*b.
                               """,
                               f1: [:forward, :forward, :left, :forward, :forward]
  end

  test "out of stage" do
    assert_scenario :out_of_stage, "bnb*", f1: [:forward]
  end

  test "out of time" do
    assert_scenario :out_of_time, "bnb*", f1: [:right, {:call, :f1}]
  end

  test "stack overflow" do
    assert_scenario :stack_overflow, "bnb*", f1: [:right, {:call, :f1}, :left]
  end

  test "stairs scenario" do
    assert_scenario :complete,
                    """
                    ..........b*b*
                    ........b*b*..
                    ......b*b*....
                    ....b*b*......
                    ..b*b*........
                    beb*..........
                    """,
                    f1: [:forward, :left, :forward, :right, {:call, :f1}]
  end

  defp assert_scenario(outcome, scenario, args) do
    {ship, stage} = parse(scenario)
    fs = %{f1: Keyword.get(args, :f1, []),
           f2: Keyword.get(args, :f2, []),
           f3: Keyword.get(args, :f3, [])}
    assert {^outcome, _, _} = run(fs, ship, stage)
  end
end
