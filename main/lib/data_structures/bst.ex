defmodule DataStructure.Bst do
  @moduledoc """
  Binary Search Tree
  """

  @type tree() :: nil | {integer(), integer(), tree(), tree()}

  @spec new() :: tree()
  def new(), do: nil

  @spec empty(tree()) :: boolean()
  def empty(nil), do: true
  def empty({}), do: true
  def empty({0, nil, nil, nil}), do: true
  def empty(_), do: false

  @spec add(tree(), any()) :: tree()
  def add(nil, number), do: {0, number, nil, nil}

  def add({_, value, nil, nil}, element) when element <= value do
    {1, value, {0, element, nil, nil}, nil}
  end

  def add({_, value, nil, nil}, element) when element > value do
    {1, value, nil, {0, element, nil, nil}}
  end

  def add({_height, value, next_left, next_right = {right_height, _, _, _}}, element)
      when element <= value do
    child_node = {child_height, _, _, _} = add(next_left, element)

    {max(child_height, right_height) + 1, value, child_node, next_right}
  end

  def add({_height, value, next_left = {left_height, _, _, _}, next_right}, element) do
    child_node = {child_height, _, _, _} = add(next_right, element)

    {max(child_height, left_height) + 1, value, next_left, child_node}
  end

  @spec contains?(tree(), any()) :: boolean()
  def contains?(nil, _), do: false
  def contains?({}, _), do: false
  def contains?({_height, value, nil, nil}, search_value) when search_value != value, do: false

  def contains?({_height, value, _next_left, _next_right}, search_value)
      when search_value == value,
      do: true

  def contains?({_height, value, next_left, _next_right}, search_value)
      when search_value < value do
    contains?(next_left, search_value)
  end

  def contains?({_height, value, _next_left, next_right}, search_value)
      when search_value > value do
    contains?(next_right, search_value)
  end

  @spec remove(tree(), any()) :: tree() | nil
  def remove(nil, _), do: nil
  # def remove({}, _), do: {}
  def remove({_height, value, nil, nil}, remove_value) when remove_value == value, do: nil
  def remove(node = {_height, _, nil, nil}, _remove_value), do: node

  def remove({_height, value, nil, next_right}, remove_value) when remove_value == value,
    do: next_right

  def remove({_height, value, next_left, nil}, remove_value) when remove_value == value,
    do: next_left

  def remove({_height, value, next_left, next_right}, remove_value) when remove_value == value do
    {new_left, new_value} = replace_node(next_left)
    {compute_height(new_left, next_right), new_value, new_left, next_right}
  end

  def remove({_height, value, next_left, next_right}, remove_value) when remove_value < value do
    new_left = remove(next_left, remove_value)
    {compute_height(new_left, next_right), value, new_left, next_right}
  end

  def remove({_height, value, next_left, next_right}, remove_value) when remove_value > value do
    new_right = remove(next_right, remove_value)
    {compute_height(next_left, new_right), value, next_left, new_right}
  end

  @spec min(tree()) :: integer() | :error
  def min(nil), do: :error
  def min({}), do: :error
  def min({_height, value, nil, _}), do: value
  def min({_height, _value, next_left, _next_right}), do: min(next_left)

  @spec max(tree()) :: integer() | :error
  def max(nil), do: :error
  def max({}), do: :error
  def max({_height, value, _, nil}), do: value
  def max({_height, _value, _next_left, next_right}), do: max(next_right)

  @spec to_list(tree()) :: [integer()] | :error
  def to_list(nil), do: []
  def to_list({}), do: []

  def to_list({_height, value, next_left, next_right}) do
    to_list(next_left) ++ [value] ++ to_list(next_right)
  end

  def to_list(_), do: :error

  @spec from_list([integer()]) :: tree() | :error
  def from_list(nil), do: :error
  def from_list([]), do: new()

  def from_list(numbers) do
    Enum.reduce(numbers, new(), fn number, tree -> add(tree, number) end)
  end

  @spec height(tree()) :: integer | nil
  def height({}), do: nil
  def height({height, _value, _next_left, _next_right}), do: height
  # def height(tree), do: find_height(tree, -1)

  @spec is_balanced?(tree()) :: boolean()
  def is_balanced?(nil), do: true

  def is_balanced?({_height, _value, nil, {right_height, _, _, _}}) when right_height > 0,
    do: false

  def is_balanced?({_height, _value, {left_height, _, _, _}, nil}) when left_height > 0,
    do: false

  def is_balanced?({_height, _value, nil, _}), do: true
  def is_balanced?({_height, _value, _, nil}), do: true

  def is_balanced?({_height, _value, {left_height, _, _, _}, {right_height, _, _, _}})
      when abs(left_height - right_height) > 1 do
    false
  end

  def is_balanced?(
        {_height, _value, next_left = {left_height, _, _, _},
         next_right = {right_height, _, _, _}}
      )
      when abs(left_height - right_height) <= 1 do
    is_balanced?(next_left) and is_balanced?(next_right)
  end

  # ===============================
  # Helper Functions
  # ===============================

  @spec replace_node(tree()) :: tree()
  def replace_node({_height, value, next_left, nil}) do
    {next_left, value}
  end

  def replace_node({_height, value, next_left, next_right}) do
    {new_right, return_value} = replace_node(next_right)

    {{compute_height(next_left, new_right), value, next_left, new_right}, return_value}
  end

  def compute_height(nil, nil), do: 0
  def compute_height(nil, {height, _, _, _}), do: height + 1
  def compute_height({height, _, _, _}, nil), do: height + 1

  def compute_height({left_height, _, _, _}, {right_height, _, _, _}),
    do: max(left_height, right_height) + 1
end
