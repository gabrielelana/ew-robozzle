defmodule Robozzle.Runner do
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

  @type steps :: non_neg_integer

  @type outcome :: :complete
                 | :incomplete
                 | :out_of_stage
                 | :out_of_time
                 | :stack_overflow

  @stack_limit 100
  @time_limit 10_000


  @spec run(functions, ship, stage, stack, steps) :: {outcome, ship, stage}
  def run(fs, ship, stage, stack \\ [{:call, :f1}], steps \\ 0) do
    case step(fs, ship, stage, stack, steps) do
      {ship, stage, stack, steps} ->
        run(fs, ship, stage, stack, steps)
      {_, _, _} = over ->
        over
    end
  end


  @spec step(functions, ship, stage, stack, steps) :: {outcome, ship, stage}
                                                    | {ship, stage, stack, steps}
  def step(_, ship, stage, [], _),
    do: {:incomplete, ship, stage}
  def step(_, ship, stage, stack, _) when length(stack) > @stack_limit,
    do: {:stack_overflow, ship, stage}
  def step(_, ship, stage, _, steps) when steps > @time_limit,
    do: {:out_of_time, ship, stage}
  def step(fs, ship, stage, [c|stack], steps) do
    case rc(c, ship, stage) do
      {:out_of_stage, ship, stage} ->
        {:out_of_stage, ship, stage}
      {ship, stage, f} ->
        stack = Map.fetch!(fs, f) |> Enum.concat(stack)
        complete?(ship, stage, stack, steps)
      {ship, stage} ->
        complete?(ship, stage, stack, steps)
    end
  end

  defp complete?(ship, stage, stack, steps) do
    if Enum.any?(stage, &match?({_, {_, :star}}, &1)) do
      {ship, stage, stack, steps + 1}
    else
      {:complete, ship, stage}
    end
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
end
