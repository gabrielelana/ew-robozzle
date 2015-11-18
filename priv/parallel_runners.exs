fs = %{f1: [:forward]}
ship = {{0,0}, :east}
stage = %{{0,0} => :blue, {1,0} => {:blue, :star}}

async = fn(_) ->
         Task.async(fn -> Robozzle.run(fs, ship, stage) end)
       end

await = fn([], await) -> :ok
          (tasks, await) ->
            receive do
              message ->
                case Task.find(tasks, message) do
                  {result, task} ->
                    IO.inspect(result)
                    await.(List.delete(tasks, task), await)
                  _ ->
                    await.(tasks, await)
                end
            end
        end

1..10
|> Enum.map(async)
|> await.(await)
