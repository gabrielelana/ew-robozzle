defmodule Robozzle do

  @type coordinate :: integer
  @type position :: {x::coordinate, y::coordinate}
  @type direction :: :north | :east | :south | :west

  @type direct_command :: :forward
                        | :right
                        | :left
                        | {:paint, color}
                        | {:call, function_name}

  @type conditional_command :: {direct_command, color}
  @type command :: direct_command | conditional_command

  @type function_name :: :f1 | :f2 | :f3
  @type functions :: %{function_name => [command]}

  @type stack :: [command]

  @type color :: :blue | :green | :red
  @type tile :: color | {color, :star}

  @type ship :: {position, direction}
  @type stage :: %{position => tile}

  @type outcome :: :complete | :incomplete | :out_of_stage

  @spec run(functions, ship, stage, stack) :: {outcome, ship, stage}
  def run(fs, ship, stage, stack \\ [{:call, :f1}])
  def run(_, ship, stage, []),
    do: {:incomplete, ship, stage}
  def run(fs, ship, stage, [c|stack]) do
    case rc(c, ship, stage) do
      {:out_of_stage, _, _} = out_of_stage ->
        out_of_stage
      {ship, stage, f} ->
        stack = Map.fetch!(fs, f) |> Enum.concat(stack)
        complete_or_run(fs, ship, stage, stack)
      {ship, stage} ->
        complete_or_run(fs, ship, stage, stack)
    end
  end

  defp complete_or_run(fs, ship, stage, stack) do
    if complete?(stage) do
      {:complete, ship, stage}
    else
      run(fs, ship, stage, stack)
    end
  end

  defp complete?(stage) do
    not Enum.any?(stage, &match?({_, {_, :star}}, &1))
  end

  @spec rc(command, ship, stage) :: {ship, stage}
                                  | {ship, stage, function_name}
                                  | {:out_of_stage, ship, stage}
  def rc({:call, f}, ship, stage),
    do: {ship, stage, f}

  def rc({:paint, color}, {p, _} = ship, stage),
    do: {ship, Map.put(stage, p, color)}

  def rc({command, color}, {p, _} = ship, stage) do
    case Map.fetch!(stage, p) do
      ^color ->
        rc(command, ship, stage)
      _ ->
        {ship, stage}
    end
  end

  def rc(:forward, {{x,y}, :north}, s), do: pick_star({{x,y-1}, :north}, s)
  def rc(:forward, {{x,y}, :east}, s), do: pick_star({{x+1,y}, :east}, s)
  def rc(:forward, {{x,y}, :south}, s), do: pick_star({{x,y+1}, :south}, s)
  def rc(:forward, {{x,y}, :west}, s), do: pick_star({{x-1,y}, :west}, s)
  def rc(:right, {p, :north}, s), do: {{p, :east}, s}
  def rc(:right, {p, :east}, s), do: {{p, :south}, s}
  def rc(:right, {p, :south}, s), do: {{p, :west}, s}
  def rc(:right, {p, :west}, s), do: {{p, :north}, s}
  def rc(:left, {p, :north}, s), do: {{p, :west}, s}
  def rc(:left, {p, :east}, s), do: {{p, :north}, s}
  def rc(:left, {p, :south}, s), do: {{p, :east}, s}
  def rc(:left, {p, :west}, s), do: {{p, :south}, s}

  defp pick_star({p, _} = ship, stage) do
    case Map.get(stage, p, :out_of_stage) do
      {color, :star} ->
        {ship, Map.put(stage, p, color)}
      :out_of_stage ->
        {:out_of_stage, ship, stage}
      _ ->
        {ship, stage}
    end
  end

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
