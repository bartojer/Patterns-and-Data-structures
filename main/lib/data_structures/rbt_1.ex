defmodule DataStructure.RedBlackTree do
  # EMPTY FUNCTION. INDICATES THE TREE IS EMPTY

  @type tree :: nil | {atom(), integer(), tree, tree}

  @spec new :: tree
  def new(), do: nil

  @spec empty?(tree) :: boolean()
  def empty?(nil), do: true
  def empty?(_), do: false

  @spec add(tree, integer()) :: tree
  def add(tree, element) do
    {:red, value, left, right} = rbt_add_helper(tree, element)
    {:black, value, left, right}
  end

  @spec min(tree) :: integer()
  def min({_color, value, nil, _}), do: value
  def min({_color, _value, left, _}), do: min(left)

  @spec max(tree) :: integer()
  def max({_color, value, _, nil}), do: value
  def max({_color, _value, _, right}), do: max(right)

  @spec contains?(tree(), integer()) :: boolean()
  def contains?(nil, _), do: false

  def contains?({_color, value, nil, nil}, search_val)
      when search_val != value,
      do: false

  def contains?({_color, value, _left, _right}, search_val)
      when search_val == value,
      do: true

  def contains?({_color, value, left, _right}, search_val)
      when search_val < value,
      do: contains?(left, search_val)

  def contains?({_color, value, _left, right}, search_val)
      when search_val > value,
      do: contains?(right, search_val)

  @spec rbt_add_helper(tree, integer()) :: tree
  defp rbt_add_helper(nil, element), do: {:red, element, nil, nil}

  defp rbt_add_helper({color, value, left, right}, element) when element < value do
    new_left = rbt_add_helper(left, element)
    balance_l({color, value, new_left, right})
  end

  defp rbt_add_helper({color, value, left, right}, element) when element > value do
    new_right = rbt_add_helper(right, element)
    balance_r({color, value, left, new_right})
  end

  # Handle duplicates - just return the tree unchanged
  defp rbt_add_helper(tree, _element), do: tree

  # BALANCE LEFT AND RIGHT SUBTREES

  @spec balance_l(tree) :: tree
  defp balance_l({:black, val_1, {:red, val_2, {:red, val_3, left_3, right_3}, right_2}, right_1}) do
    {:red, val_2, {:black, val_3, left_3, right_3}, {:black, val_1, right_2, right_1}}
  end

  defp balance_l({:black, val_1, {:red, val_2, left_2, {:red, val_3, left_3, right_3}}, right_1}) do
    transform_to_base_case = {:red, val_3, {:red, val_2, left_2, left_3}, right_3}

    balance_l({:black, val_1, transform_to_base_case, right_1})
  end

  defp balance_l(tree), do: tree

  @spec balance_r(tree) :: tree
  defp balance_r({:black, val_1, left_1, {:red, val_2, left_2, {:red, val_3, left_3, right_3}}}) do
    {:red, val_2, {:black, val_3, left_1, left_2}, {:black, val_1, left_3, right_3}}
  end

  defp balance_r({:black, val_1, left_1, {:red, val_2, {:red, val_3, left_3, right_3}, right_2}}) do
    transform_to_base_case = {:red, val_3, left_3, {:red, val_2, right_2, right_3}}

    balance_r({:black, val_1, left_1, transform_to_base_case})
  end

  defp balance_r(tree), do: tree

  # REMOVE FUNCTION

  @spec remove(tree, integer()) :: tree
  def remove(nil, _target), do: nil

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
        balance_l({color, value, left, paint_black(right)})

      right == nil ->
        balance_r({color, value, paint_black(left), right})

      # new_value is also in order successor
      true ->
        {new_value, new_right} = remove_min(right)
        # Rebalance the right subtree after finding the in-order successor

        IO.puts("IN ORDER SUCCESSOR FOUND: #{new_value}")

        balanced_right = balance_r(new_right)
        balance_r({color, new_value, left, balanced_right})
    end
  end

  @spec remove_min(tree) :: {integer(), tree}
  defp remove_min({_color, value, nil, right}), do: {value, right}

  defp remove_min({color, value, left, right}) do
    {min, new_left} = remove_min(left)
    balanced_left = balance_l(new_left)
    {min, balance_l({color, value, balanced_left, right})}
  end

  @spec node_color(tree) :: :red | :black
  defp node_color(nil), do: :black
  defp node_color({color, _, _, _}), do: color

  @spec paint_black(tree) :: tree
  defp paint_black(nil), do: nil
  defp paint_black({_, value, left, right}), do: {:black, value, left, right}

  @spec to_list(tree) :: [integer]
  def to_list(nil), do: []

  def to_list({_color, value, left, right}) do
    to_list(left) ++ [value] ++ to_list(right)
  end

  @spec from_list([integer]) :: tree
  def from_list([]), do: new()

  def from_list(numbers) do
    Enum.reduce(numbers, new(), fn number, tree -> add(tree, number) end)
  end

  def from_list(other), do: other
end
