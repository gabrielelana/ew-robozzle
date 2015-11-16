defmodule Robozzle do

  @type coordinate :: integer
  @type position :: {x::coordinate, y::coordinate}
  @type direction :: :north | :east | :south | :west

  @type color :: :blue | :green | :red
  @type tile :: color | {color, :star}

  @type ship :: {position, direction}
  @type stage :: %{position => tile}

  @spec parse(String.t) :: {ship, stage} | {:error, reason::String.t}
  def parse(string), do: {:error, "Not yet implemented"}
end

ExUnit.start

defmodule Robozzle.Test do
  use ExUnit.Case
  import Robozzle

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
