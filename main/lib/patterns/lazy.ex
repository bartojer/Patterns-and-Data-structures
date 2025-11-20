defmodule Lazy do
  def squares_stream do
    Stream.unfold(1, fn x -> {x * x, x + 1} end)
  end

  def start_squares_process(starting_number \\ 1) do
    spawn(fn -> squares_loop(starting_number) end)
  end

  def next_square(pid) do
    send(pid, {self(), :next})

    receive do
      square -> square
    end
  end

  defp squares_loop(number) do
    receive do
      {caller, :next} ->
        number = number + 1
        send(caller, number * number)
        squares_loop(number)
    end
  end
end
