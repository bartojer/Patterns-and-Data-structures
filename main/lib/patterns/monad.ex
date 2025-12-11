defmodule Maybe do
  def bind({:ok, data}, func), do: func.(data)
  def bind({:error, _data}, _func), do: :error

  def unit(data), do: {:ok, data}
end

get_age = fn user ->
  case user do
    %{age: age} -> {:ok, age}
    _ -> {:error, "no age"}
  end
end

increment_age = fn age -> {:ok, age + 1} end

user = {:ok, %{age: 17, name: "Phizzler"}}

result =
  user
  |> Maybe.bind(get_age)
  |> Maybe.bind(increment_age)

IO.inspect(result)
