defmodule Robozzle.Parser do
  @type ship :: Robozzle.Runner.ship
  @type stage :: Robozzle.Runner.stage
  @type position :: Robozzle.Runner.position

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
  defp do_parse(<<"\n", rest::binary>>, {_, y}, ship, stage) do
    do_parse(rest, {0, y+1}, ship, stage)
  end
  defp do_parse(<<"..", rest::binary>>, {x, y}, ship, stage) do
    do_parse(rest, {x+1, y}, ship, stage)
  end
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
