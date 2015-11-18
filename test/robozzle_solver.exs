defmodule Robozzle.SolverTest do
  use ExUnit.Case, async: true

  import Robozzle.Solver

  test "functions_from/2" do
    assert %{f1: []} == functions_from([], %{f1: 2})
    assert %{f1: [:forward]} == functions_from([:forward], %{f1: 2})
    assert %{f1: [:forward, :forward]} == functions_from([:forward, :forward], %{f1: 2})

    assert %{f1: [], f2: []} == functions_from([], %{f1: 1, f2: 1})
    assert %{f1: [:forward], f2: []} == functions_from([:forward], %{f1: 1, f2: 1})
    assert %{f1: [:forward], f2: [:forward]} ==
           functions_from([:forward, :forward], %{f1: 1, f2: 1})

    assert %{f1: [:forward]} == functions_from([:forward, :nop], %{f1: 2})
    assert %{f1: [:forward], f2: [:forward]} ==
           functions_from([:forward, :nop, :forward, :nop], %{f1: 2, f2: 2})
  end

  test "next_solutions" do
    assert [:forward] in next_solutions([], %{f1: 2})
    assert [:nop] in next_solutions([], %{f1: 2})
    assert [{:call, :f1}] in next_solutions([], %{f1: 2})
    assert [{:call, :f2}] in next_solutions([], %{f1: 2, f2: 2})

    assert [{:paint, :green}] in next_solutions([], %{f1: 2})
    assert [{:forward, :green}] in next_solutions([], %{f1: 2})
    assert [{{:paint, :red}, :green}] in next_solutions([], %{f1: 2})
  end

  test "next_solutions append to previous solution" do
    assert [:forward, :forward] in next_solutions([:forward], %{f1: 2})
    assert [:forward, :right] in next_solutions([:forward], %{f1: 2})
    assert [:forward, :nop] in next_solutions([:forward], %{f1: 2})

    refute [:forward, :nop, :forward] in next_solutions([:forward, :nop], %{f1: 3})
    assert [:forward, :nop, :nop] in next_solutions([:forward, :nop], %{f1: 3})
  end

  test "no next solutions when finished" do
    assert [] == next_solutions([:forward, :forward], %{f1: 2})
  end
end
