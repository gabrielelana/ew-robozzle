defmodule Robozzle do

  @type coordinate :: integer
  @type position :: {x::coordinate, y::coordinate}
  @type direction :: :north | :east | :south | :west

  @type color :: :blue | :green | :red
  @type tile :: color | {color, :star}

  @type ship :: {position, direction}
  @type stage :: %{position => tile}

  @spec parse(String.t) :: {ship, stage} | {:error, reason::String.t}
  def parse(string) do
    case do_parse(string, {0,0}, nil, %{}) do
      {nil, _} ->
        {:error, "Missing ship in scenario"}
      result ->
        result
    end
  end

  @spec do_parse(String.t, position, ship | nil, stage) :: {ship | nil, stage}
  defp do_parse("", _, ship, stage), do: {ship, stage}
  defp do_parse(<<c::utf8, ".", rest::binary>>, {x, y} = p, ship, stage) do
    do_parse(rest, {x+1, y}, ship, Map.put(stage, p, do_parse(<<c::utf8>>)))
  end
  defp do_parse(<<c::utf8, "*", rest::binary>>, {x, y} = p, ship, stage) do
    do_parse(rest, {x+1, y}, ship, Map.put(stage, p, {do_parse(<<c::utf8>>), :star}))
  end
  defp do_parse(<<c::utf8, d::utf8, rest::binary>>, {x, y} = p, nil, stage) do
    do_parse(rest, {x+1, y}, {p, do_parse(<<d::utf8>>)}, Map.put(stage, p, do_parse(<<c::utf8>>)))
  end

  defp do_parse("b"), do: :blue
  defp do_parse("r"), do: :red
  defp do_parse("g"), do: :green
  defp do_parse("n"), do: :north
  defp do_parse("e"), do: :east
  defp do_parse("s"), do: :south
  defp do_parse("w"), do: :west
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
