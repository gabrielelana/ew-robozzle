ExUnit.start()

defmodule Robozzle.Test.Macro do
  defmacro __using__(_opts) do
    quote do
      import Robozzle.Test.Macro
      import Robozzle.Runner
      import Robozzle.Parser

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
