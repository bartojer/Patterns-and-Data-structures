defmodule DataStructure.BstComp do
  @moduledoc """
  Binary Search Tree
  """

  @type tree() :: nil | {integer(), integer(), tree(), tree()}

  @spec new() :: tree()
  def new(), do: nil

  @spec empty?(tree()) :: boolean()
  def empty?(nil), do: true
  def empty?({}), do: true
  def empty?({0, nil, nil, nil}), do: true
  def empty?(_), do: false

  @spec add(tree(), integer()) :: tree()
  def add(nil, element), do: {0, element, nil, nil}

  def add({_height, value, nil, nil}, element) when element <= value do
    {1, value, {0, element, nil, nil}, nil}
  end

  def add({_height, value, nil, nil}, element) when element > value do
    {1, value, nil, {0, element, nil, nil}}
  end

  def add({_height, value, nil, next_right}, element) when element <= value do
    child_node = add(nil, element)
    {compute_height(child_node, next_right), value, child_node, next_right}
  end

  def add({_height, value, nil, next_right}, element) when element > value do
    child_node = add(next_right, element)
    {compute_height(nil, child_node), value, nil, child_node}
  end

  def add({_height, value, next_left, nil}, element) when element <= value do
    child_node = add(next_left, element)
    {compute_height(child_node, nil), value, child_node, nil}
  end

  def add({_height, value, next_left, nil}, element) when element > value do
    child_node = add(nil, element)
    {compute_height(next_left, child_node), value, next_left, child_node}
  end

  def add({_height, value, next_left, next_right}, element) when element <= value do
    child_node = add(next_left, element)
    {compute_height(child_node, next_right), value, child_node, next_right}
  end

  def add({_height, value, next_left, next_right}, element) when element > value do
    child_node = add(next_right, element)
    {compute_height(next_left, child_node), value, next_left, child_node}
  end

  @spec contains?(tree(), integer()) :: boolean()
  def contains?(nil, _), do: false
  def contains?({}, _), do: false

  def contains?({_h, value, nil, nil}, search_val)
      when search_val != value,
      do: false

  def contains?({_h, value, _next_left, _next_right}, search_val)
      when search_val == value,
      do: true

  def contains?({_h, value, next_left, _next_right}, search_val)
      when search_val < value,
      do: contains?(next_left, search_val)

  def contains?({_h, value, _next_left, next_right}, search_val)
      when search_val > value,
      do: contains?(next_right, search_val)

  @spec remove(tree(), integer()) :: tree() | nil
  def remove(nil, _), do: nil
  def remove({}, _), do: nil
  def remove({_h, value, nil, nil}, remove_val) when remove_val == value, do: nil
  def remove(node = {_h, _v, nil, nil}, _remove_val), do: node

  def remove({_h, value, nil, next_right}, remove_val) when remove_val == value,
    do: next_right

  def remove({_h, value, next_left, nil}, remove_val) when remove_val == value,
    do: next_left

  def remove({_h, value, next_left, next_right}, remove_val) when remove_val == value do
    {new_left, new_value} = replace_node(next_left)
    {compute_height(new_left, next_right), new_value, new_left, next_right}
  end

  def remove({_h, value, next_left, next_right}, remove_val) when remove_val < value do
    new_left = remove(next_left, remove_val)
    {compute_height(new_left, next_right), value, new_left, next_right}
  end

  def remove({_h, value, next_left, next_right}, remove_val) when remove_val > value do
    new_right = remove(next_right, remove_val)
    {compute_height(next_left, new_right), value, next_left, new_right}
  end

  @spec min(tree()) :: integer() | :error
  def min(nil), do: :error
  def min({}), do: :error
  def min({_h, value, nil, _}), do: value
  def min({_h, _value, next_left, _}), do: min(next_left)

  @spec max(tree()) :: integer() | :error
  def max(nil), do: :error
  def max({}), do: :error
  def max({_h, value, _, nil}), do: value
  def max({_h, _value, _, next_right}), do: max(next_right)

  @spec to_list(tree()) :: [integer()] | :error
  def to_list(nil), do: []
  def to_list({}), do: []

  def to_list({_height, value, next_left, next_right}) do
    to_list(next_left) ++ [value] ++ to_list(next_right)
  end

  def to_list(_), do: :error

  @spec from_list([integer()]) :: tree()
  def from_list([]), do: new()

  def from_list(numbers) do
    Enum.reduce(numbers, new(), fn number, tree -> add(tree, number) end)
  end

  def from_list(other), do: other

  @spec height(tree()) :: integer()
  def height(nil), do: 0
  def height({}), do: 0
  def height({height, _val, _left, _right}), do: height

  @spec is_balanced?(tree()) :: boolean()
  def is_balanced?(nil), do: true

  def is_balanced?({_h, _val, nil, {right_height, _, _, _}}) when right_height > 0,
    do: false

  def is_balanced?({_h, _val, {left_height, _, _, _}, nil}) when left_height > 0,
    do: false

  def is_balanced?({_h, _val, nil, _}), do: true
  def is_balanced?({_h, _val, _, nil}), do: true

  def is_balanced?({_h, _val, {l_height, _, _, _}, {r_height, _, _, _}})
      when abs(l_height - r_height) > 1,
      do: false

  def is_balanced?({_h, _val, next_left, next_right}),
    do: is_balanced?(next_left) and is_balanced?(next_right)

  # ==========================
  # HELPER FUNCTIONS
  # ==========================

  @spec replace_node(tree()) :: tree()
  def replace_node({_h, value, next_left, nil}), do: {next_left, value}

  def replace_node({_h, value, next_left, next_right}) do
    {new_right, return_val} = replace_node(next_right)
    {{compute_height(next_left, new_right), value, next_left, new_right}, return_val}
  end

  def compute_height(nil, nil), do: 0
  def compute_height(nil, {height, _, _, _}), do: height + 1
  def compute_height({height, _, _, _}, nil), do: height + 1

  def compute_height({l_height, _, _, _}, {r_height, _, _, _}),
    do: max(l_height, r_height) + 1
end
