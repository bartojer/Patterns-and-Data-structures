defmodule Factory do
  def calculator(operation) do
    case operation do
      "+" -> fn x, y -> x + y end
      "-" -> fn x, y -> x - y end
      "*" -> fn x, y -> x * y end
      "/" -> fn x, y -> x / y end
    end
  end

  def constant_int(number) do
    fn -> number end
  end

  def timestamps(time_zone, range) do
    Enum.map_reduce(1..range, DateTime.now!(time_zone), fn _, timestamp ->
      DateTime.add(timestamp, 60)
    end)
  end

  def stack(initial_values) do
    initial_values
  end
end
