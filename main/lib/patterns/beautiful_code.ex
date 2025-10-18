# In your editor, write a pipeline function that
# filters even numbers,
# squares them, and
# sums them from a list.
# Ensure the pipeline is beautifully readable.

defmodule Pipeline do
  # Too much code for this problem, better if problem was more complex
  def keep_evens(number_list) do
    Enum.filter(number_list, fn number -> rem(number, 2) == 0 end)
  end

  def square_list(number_list) do
    Enum.map(number_list, fn number -> number * number end)
  end

  def sum_list(number_list) do
    Enum.sum(number_list)
  end

  def sum_evens_from_list(number_list) do
    even_numbers = keep_evens(number_list)

    squared_numbers = square_list(even_numbers)

    sum = sum_list(squared_numbers)

    sum
  end

  # Better given the complexity is low
  def sum_evens_from_list2(number_list) do
    number_list
    |> Enum.filter(fn number -> rem(number, 2) == 0 end)
    |> Enum.map(fn number -> number * number end)
    |> Enum.sum()
  end

  def smthn(number_list) do
    Enum.sum(Enum.map(Enum.filter(number_list, fn number -> rem(number, 2) == 0 end), fn number -> number * number end))
  end
end
