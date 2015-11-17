defmodule Robozzle.ParserTest do
  use ExUnit.Case, async: true
  import Robozzle.Parser

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
