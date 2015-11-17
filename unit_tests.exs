defmodule Robozzle.Test do
  use ExUnit.Case
  import Robozzle

  test "run/3 out of time" do
    {ship, stage} = parse("beb.b.b*")
    functions = %{f1: [:right, {:call, :f1}]}

    assert {:out_of_time, _, _} = run(functions, ship, stage)
  end

  test "run/3 stack overflow" do
    {ship, stage} = parse("beb.b.b*")
    functions = %{f1: [:right, {:call, :f1}, :right]}

    assert {:stack_overflow, _, _} = run(functions, ship, stage)
  end

  test "run/3 with stack" do
    {ship, stage} = parse("beb.b.b*")
    {ship_after, stage_after} = parse("b.b.b.be")
    functions = %{f1: [:forward, {:call, :f2}, :forward],
                  f2: [:forward]}

    assert {:complete, ship_after, stage_after} == run(functions, ship, stage)
  end

  test "run/3 with multiple functions" do
    {ship, stage} = parse("beb.b.b*")
    {ship_after, stage_after} = parse("b.b.b.be")
    functions = %{f1: [:forward, {:call, :f2}],
                  f2: [:forward, {:call, :f3}],
                  f3: [:forward]}

    assert {:complete, ship_after, stage_after} == run(functions, ship, stage)
  end

  test "run/3 out of stage" do
    {ship, stage} = parse("bnb.b*")

    functions = %{f1: [:forward]}
    assert {:out_of_stage, {{0,-1}, :north}, stage} == run(functions, ship, stage)

    functions = %{f1: [:forward, :forward]}
    assert {:out_of_stage, {{0,-1}, :north}, stage} == run(functions, ship, stage)
  end

  test "run/3" do
    {ship, stage} = parse("beb.b.b*")

    functions = %{f1: []}
    assert {:incomplete, ship, stage} == run(functions, ship, stage)

    functions = %{f1: [:forward]}
    {ship_after, stage_after} = parse("b.beb.b*")
    assert {:incomplete, ship_after, stage_after} == run(functions, ship, stage)

    functions = %{f1: [:forward, :forward]}
    {ship_after, stage_after} = parse("b.b.beb*")
    assert {:incomplete, ship_after, stage_after} == run(functions, ship, stage)

    functions = %{f1: [:forward, :forward, :forward]}
    {ship_after, stage_after} = parse("b.b.b.be")
    assert {:complete, ship_after, stage_after} == run(functions, ship, stage)
  end

  test "rc/3 call commands" do
    {ship, stage} = parse("beb.b.")

    assert {ship, stage, :f1} == rc({:call, :f1}, ship, stage)
  end

  test "rc/3 conditional commands" do
    {_, stage} = parse("""
                       b.b.b.
                       b.beb.
                       b.b.b.
                       """)

    assert {{{1,0}, :north}, stage} == rc({:forward, :blue}, {{1,1}, :north}, stage)
    assert {{{1,1}, :north}, stage} == rc({:forward, :green}, {{1,1}, :north}, stage)
    assert {{{1,1}, :north}, stage} == rc({:forward, :red}, {{1,1}, :north}, stage)
  end

  test "rc/3 paint commands" do
    {_, stage} = parse("""
                       b.b.b.
                       b.beb.
                       b.b.b.
                       """)

    expected = Map.put(stage, {1,1}, :green)
    assert {{{1,1}, :north}, expected} == rc({:paint, :green}, {{1,1}, :north}, stage)
  end

  test "rc/3 picks the star" do
    {_, stage} = parse("""
                       b.b*b.
                       b*beb*
                       b.b*b.
                       """)

    expected = Map.put(stage, {1,0}, :blue)
    assert {{{1,0}, :north}, expected} == rc(:forward, {{1,1}, :north}, stage)

    expected = Map.put(stage, {2,1}, :blue)
    assert {{{2,1}, :east}, expected} == rc(:forward, {{1,1}, :east}, stage)

    expected = Map.put(stage, {1,2}, :blue)
    assert {{{1,2}, :south}, expected} == rc(:forward, {{1,1}, :south}, stage)

    expected = Map.put(stage, {0,1}, :blue)
    assert {{{0,1}, :west}, expected} == rc(:forward, {{1,1}, :west}, stage)
  end

  test "rc/3 move commands" do
    {_, stage} = parse("""
                       b.b.b.
                       b.beb.
                       b.b.b.
                       """)

    assert {{{1,0}, :north}, stage} == rc(:forward, {{1,1}, :north}, stage)
    assert {{{2,1}, :east}, stage} == rc(:forward, {{1,1}, :east}, stage)
    assert {{{1,2}, :south}, stage} == rc(:forward, {{1,1}, :south}, stage)
    assert {{{0,1}, :west}, stage} == rc(:forward, {{1,1}, :west}, stage)

    assert {{{1,1}, :east}, stage} == rc(:right, {{1,1}, :north}, stage)
    assert {{{1,1}, :south}, stage} == rc(:right, {{1,1}, :east}, stage)
    assert {{{1,1}, :west}, stage} == rc(:right, {{1,1}, :south}, stage)
    assert {{{1,1}, :north}, stage} == rc(:right, {{1,1}, :west}, stage)

    assert {{{1,1}, :west}, stage} == rc(:left, {{1,1}, :north}, stage)
    assert {{{1,1}, :north}, stage} == rc(:left, {{1,1}, :east}, stage)
    assert {{{1,1}, :east}, stage} == rc(:left, {{1,1}, :south}, stage)
    assert {{{1,1}, :south}, stage} == rc(:left, {{1,1}, :west}, stage)
  end

  test "parse/1 multiple lines" do
    stage = %{{0,0} => :blue,
              {1,0} => :blue,
              {2,0} => :blue,
              {0,1} => :blue,
              {1,1} => {:blue, :star},
              {2,1} => :blue}
    ship = {{1,0}, :south}
    assert {ship, stage} == parse(
      """
      b.bsb.
      b.b*b.
      """
    )
  end

  test "parse/1 one line with multiple colors" do
    stage = %{{0,0} => :blue,
              {1,0} => :green,
              {2,0} => {:red, :star}}
    ship = {{0, 0}, :east}
    assert {ship, stage} == parse("beg.r*")
  end

  test "parse/1 one line" do
    stage = %{{0,0} => :blue,
              {1,0} => :blue,
              {2,0} => {:blue, :star}}
    ship = {{0,0}, :east}
    assert {ship, stage} == parse("beb.b*")
  end
end
