defmodule DataStructures.RedBlackTreeComp do
  def new(), do: nil

  def empty?(nil), do: true
  def empty?(_), do: false

  def add(tree, element) do
    {:red, value, left, right} = add_helper(tree, element)
    {:black, value, left, right}
  end

  def contains?(nil, _), do: false
  def contains?({_, val, nil, nil}, target) when target != val, do: false
  def contains?({_c, val, _left, _right}, target) when target == val, do: true
  def contains?({_c, val, _left, right}, target) when target > val, do: contains?(right, target)
  def contains?({_c, val, left, _right}, target) when target < val, do: contains?(left, target)

  def remove(nil, _), do: nil

  def remove({color, value, left, right}, target) when target < value do
    new_left = remove(left, target)
    balance_l({color, value, new_left, right})
  end

  def remove({color, value, left, right}, target) when target > value do
    new_right = remove(right, target)
    balance_r({color, value, left, new_right})
  end

  def remove({color, value, left, right}, target) when target == value do
    cond do
      left == nil and right == nil ->
        nil

      left == nil ->
        paint_black(right)

      right == nil ->
        paint_black(left)

      true ->
        {new_value, new_right} = remove_min(right)
        balance_r({color, new_value, left, new_right})
    end
  end

  def min(nil), do: nil
  def min({_color, value, nil, _right}), do: value
  def min({_color, _v, left, _right}), do: min(left)

  def max(nil), do: nil
  def max({_color, value, _left, nil}), do: value
  def max({_color, _v, _left, right}), do: max(right)

  def to_list(nil), do: []

  def to_list({_color, value, left, right}) do
    to_list(left) ++ [value] ++ to_list(right)
  end

  def from_list([]), do: new()

  def from_list(numbers) do
    Enum.reduce(numbers, new(), fn number, tree -> add(tree, number) end)
  end

  defp add_helper(nil, element), do: {:red, element, nil, nil}

  defp add_helper({color, value, left, right}, element) when element < value do
    new_left = add_helper(left, element)
    balance_l({color, value, new_left, right})
  end

  defp add_helper({color, value, left, right}, element) when element >= value do
    new_right = add_helper(right, element)
    balance_r({color, value, left, new_right})
  end

  defp balance_l({:black, val_1, {:red, val_2, {:red, val_3, left_3, right_3}, right_2}, right_1}) do
    {:red, val_2, {:black, val_3, left_3, right_3}, {:black, val_1, right_2, right_1}}
  end

  defp balance_l({:black, val_1, {:red, val_2, left_2, {:red, val_3, left_3, right_3}}, right_1}) do
    left_to_base = {:red, val_3, {:red, val_2, left_2, left_3}, right_3}
    balance_l({:black, val_1, left_to_base, right_1})
  end

  defp balance_l(tree), do: tree

  defp balance_r({:black, val_1, left_1, {:red, val_2, left_2, {:red, val_3, left_3, right_3}}}) do
    {:red, val_2, {:black, val_1, left_1, left_2}, {:black, val_3, left_3, right_3}}
  end

  defp balance_r({:black, val_1, left_1, {:red, val_2, {:red, val_3, left_3, right_3}, right_2}}) do
    right_to_base = {:red, val_3, left_3, {:red, val_2, right_2, right_3}}
    balance_r({:black, val_1, left_1, right_to_base})
  end

  defp balance_r(tree), do: tree

  defp remove_min({_color, value, nil, right}), do: {value, right}

  defp remove_min({color, value, left, right}) do
    {min, new_left} = remove_min(left)
    {min, balance_l({color, value, new_left, right})}
  end

  defp paint_black(nil), do: nil
  defp paint_black({_color, value, left, right}), do: {:black, value, left, right}
end
