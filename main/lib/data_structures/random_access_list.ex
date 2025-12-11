defmodule DataStructures.RAL do
  @moduledoc """
  Binary Random Access List - a functional data structure providing O(log n) random access
  while maintaining O(1) cons operation. Implemented as a forest of complete binary trees
  with sizes that are powers of 2 (1, 2, 4, 8, 16, ...).
  """

  # Tree can be a leaf {value, nil, nil} or internal node {leaf_count, left, right}
  @type tree :: {integer(), tree() | nil, tree() | nil}
  @type forest :: [tree()]
  @type ral :: forest()

  # ===============================
  # Public API
  # ===============================

  @doc "Creates an empty Random Access List"
  @spec new() :: ral()
  def new(), do: []

  @doc "Checks if the Random Access List is empty"
  @spec empty?(ral()) :: boolean()
  def empty?([]), do: true
  def empty?(_), do: false

  @doc "Adds an element to the front of the list (O(1) amortized)"
  @spec cons(integer(), ral()) :: ral()
  def cons(element, forest) do
    cons_tree({element, nil, nil}, forest)
  end

  # Helper to cons a tree into the forest
  defp cons_tree(tree, []) do
    [tree]
  end

  defp cons_tree(tree, [first | rest]) do
    size1 = size_of_tree(tree)
    size2 = size_of_tree(first)

    if size1 == size2 do
      # Merge the two trees of equal size
      merged = {size1 + size2, tree, first}
      cons_tree(merged, rest)
    else
      # Sizes differ, just prepend
      [tree, first | rest]
    end
  end

  @doc "Retrieves the first element of the list (O(1))"
  @spec head(ral()) :: integer() | nil
  def head([]), do: nil

  def head([{value, nil, nil} | _rest]) do
    value
  end

  def head([{_size, left, _right} | _rest]) do
    # For internal nodes, go to the leftmost leaf
    leftmost_value(left)
  end

  @doc "Retrieves the last element of the list (O(log n))"
  @spec tail(ral()) :: integer() | nil
  def tail([]), do: nil

  def tail(forest) do
    # Last element is the rightmost leaf of the last tree
    case List.last(forest) do
      nil -> nil
      tree -> rightmost_value(tree)
    end
  end

  @doc "Retrieves the element at the given index (0-based) (O(log n))"
  @spec lookup(ral(), integer()) :: integer() | nil
  def lookup(_forest, index) when index < 0, do: nil
  def lookup([], _index), do: nil

  def lookup([tree | rest], index) do
    tree_size = size_of_tree(tree)

    cond do
      index < tree_size ->
        # Element is in this tree
        lookup_in_tree(tree, index)

      true ->
        # Skip this tree and continue
        lookup(rest, index - tree_size)
    end
  end

  @doc "Updates the element at the given index (O(log n))"
  @spec update(ral(), integer(), integer()) :: ral()
  def update(forest, index, _new_value) when index < 0, do: forest
  def update([], _index, _new_value), do: []

  def update([tree | rest], index, new_value) do
    tree_size = size_of_tree(tree)

    cond do
      index < tree_size ->
        # Update is in this tree
        updated_tree = update_in_tree(tree, index, new_value)
        [updated_tree | rest]

      true ->
        # Skip this tree and continue
        [tree | update(rest, index - tree_size, new_value)]
    end
  end

  @doc "Converts the Random Access List into a standard list (O(n))"
  @spec toList(ral()) :: [integer()]
  def toList([]), do: []

  def toList(forest) do
    Enum.flat_map(forest, &tree_to_list/1)
  end

  @doc "Constructs a Random Access List from a standard list (O(n))"
  @spec fromList([integer()]) :: ral()
  def fromList([]), do: []

  def fromList(list) do
    list
    |> Enum.reverse()
    |> Enum.reduce(new(), fn element, acc -> cons(element, acc) end)
  end

  # ===============================
  # Private Helper Functions
  # ===============================

  # Get the number of leaves in a tree
  @spec size_of_tree(tree()) :: integer()
  defp size_of_tree({_value, nil, nil}), do: 1
  defp size_of_tree({size, _left, _right}), do: size

  # Get leftmost value in a tree
  @spec leftmost_value(tree()) :: integer()
  defp leftmost_value({value, nil, nil}), do: value
  defp leftmost_value({_size, left, _right}), do: leftmost_value(left)

  # Get rightmost value in a tree
  @spec rightmost_value(tree()) :: integer()
  defp rightmost_value({value, nil, nil}), do: value
  defp rightmost_value({_size, _left, right}), do: rightmost_value(right)

  # Lookup within a single tree using binary navigation
  @spec lookup_in_tree(tree(), integer()) :: integer() | nil
  defp lookup_in_tree({value, nil, nil}, 0), do: value
  defp lookup_in_tree({_value, nil, nil}, _index), do: nil

  defp lookup_in_tree({size, left, right}, index) do
    left_size = div(size, 2)

    cond do
      index < left_size ->
        # Go left
        lookup_in_tree(left, index)

      true ->
        # Go right
        lookup_in_tree(right, index - left_size)
    end
  end

  # Update within a single tree
  @spec update_in_tree(tree(), integer(), integer()) :: tree()
  defp update_in_tree({_value, nil, nil}, 0, new_value), do: {new_value, nil, nil}
  defp update_in_tree({value, nil, nil}, _index, _new_value), do: {value, nil, nil}

  defp update_in_tree({size, left, right}, index, new_value) do
    left_size = div(size, 2)

    cond do
      index < left_size ->
        # Update left
        {size, update_in_tree(left, index, new_value), right}

      true ->
        # Update right
        {size, left, update_in_tree(right, index - left_size, new_value)}
    end
  end

  # Convert a tree to a list
  @spec tree_to_list(tree()) :: [integer()]
  defp tree_to_list({value, nil, nil}), do: [value]

  defp tree_to_list({_size, left, right}) do
    tree_to_list(left) ++ tree_to_list(right)
  end
end
