defmodule Robozzle.AcceptanceTest.Macro do
  defmacro __using__(_opts) do
    quote do
      import Robozzle.AcceptanceTest.Macro
      import Robozzle

      Module.put_attribute __MODULE__, :acceptance_counter, 0
    end
  end

  defmacro scenario(outcome, block) do
    quote do
      Module.put_attribute(__MODULE__, :acceptance_counter,
        Module.get_attribute(__MODULE__, :acceptance_counter) + 1)
      scenario(unquote(outcome),
               "##{Module.get_attribute(__MODULE__, :acceptance_counter)}",
               unquote(block))
    end
  end

  defmacro scenario(outcome, title, do: {:__block__, _, block}) do
    quote do
      test "acceptance #{unquote(title)}" do
        {ship, stage} = parse(unquote(scenario_from block))
        fs = %{f1: unquote(function_from :f1, block),
               f2: unquote(function_from :f2, block),
               f3: unquote(function_from :f3, block)}
        outcome = unquote(outcome)
        assert {^outcome, _, _} = run(fs, ship, stage)
      end
    end
  end

  defp scenario_from(block), do: Enum.find(block, &is_binary/1)
  defp function_from(f, block), do: Enum.find(block, &match?({^f, _, _}, &1))
                                    |> (fn({_, _, [cs]}) -> cs; (nil) -> [] end).()
end

defmodule Robozzle.AcceptanceTest do
  use ExUnit.Case
  use Robozzle.AcceptanceTest.Macro

  scenario(:incomplete) do
    """
    beb.b*
    """
    f1 []
  end

  scenario(:incomplete) do
    """
    beb.b*
    """
    f1 [:forward]
  end

  scenario(:complete) do
    """
    beb.b*
    """
    f1 [:forward, :forward]
  end

  scenario(:complete) do
    """
    b.b.b.bsb.b.b.
    b.b.b.b.b.b.b.
    b.b.b.b.b.b*b.
    """
    f1 [:forward, :forward, :left, :forward, :forward]
  end

  scenario(:out_of_stage) do
    """
    bnb*
    """
    f1 [:forward]
  end

  scenario(:stack_overflow) do
    """
    bnb*
    """
    f1 [:right, {:call, :f1}, :left]
  end

  scenario(:out_of_time) do
    """
    bnb*
    """
    f1 [:right, {:call, :f1}]
  end

  scenario(:complete, "stairs") do
    """
    ..........b*b*
    ........b*b*..
    ......b*b*....
    ....b*b*......
    ..b*b*........
    beb*..........
    """
    f1 [:forward, :left, :forward, :right, {:call, :f1}]
  end
end
