defmodule DataStructures.RalComp do
  @type tree :: {integer(), tree() | nil, tree() | nil}
  @type ral :: [tree()]

  @spec new() :: ral()
  def new(), do: []

  @spec empty?(ral()) :: boolean()
  def empty?([]), do: true
  def empty?(_), do: false

  @spec cons(ral(), integer()) :: ral()
  def cons(ral, element) do
    merge(ral, {element, nil, nil})
  end

  @spec head(ral()) :: integer() | nil
  def head([]), do: nil
  def head([{value, nil, nil} | _rest]), do: value

  def head([{_size, left, _right} | _rest]) do
    leftmost_value(left)
  end

  @spec tail(ral()) :: integer() | nil
  def tail(ral) do
    case List.last(ral) do
      nil -> nil
      tree -> rightmost_value(tree)
    end
  end

  @spec lookup(ral(), non_neg_integer()) :: integer() | nil
  def lookup(_ral, index) when index < 0, do: nil
  def lookup([], _index), do: nil

  def lookup([tree | rest], index) do
    tree_size = size_of_tree(tree)

    cond do
      index < tree_size ->
        lookup_in_tree(tree, index)

      true ->
        lookup(rest, index - tree_size)
    end
  end

  @spec update(ral(), integer(), integer()) :: ral()
  def update([], _, _), do: []
  def update(ral, index, _new_value) when index < 0, do: ral

  def update([tree | rest], index, new_value) do
    tree_size = size_of_tree(tree)

    cond do
      index < tree_size ->
        [update_tree(tree, index, new_value) | rest]

      true ->
        [tree | update(rest, index - tree_size, new_value)]
    end
  end

  @spec to_list(ral()) :: [integer()]
  def to_list([]), do: []

  def to_list(ral) do
    Enum.flat_map(ral, fn tree -> tree_to_list(tree) end)
  end

  @spec from_list([integer()]) :: ral()
  def from_list([]), do: new()

  def from_list(numbers) do
    numbers
    |> Enum.reverse()
    |> Enum.reduce(new(), fn number, tree -> cons(tree, number) end)
  end

  @spec size_of_tree(tree()) :: non_neg_integer()
  defp size_of_tree({_value, nil, nil}), do: 1
  defp size_of_tree({size, _left, _right}), do: size

  @spec merge(ral(), tree()) :: ral()
  def merge([], tree), do: [tree]

  def merge([tree_1 | rest], new_tree) do
    size_1 = size_of_tree(new_tree)
    size_2 = size_of_tree(tree_1)

    cond do
      size_1 == size_2 ->
        merged = {size_1 + size_2, new_tree, tree_1}
        merge(rest, merged)

      true ->
        [new_tree, tree_1 | rest]
    end
  end

  @spec leftmost_value(tree()) :: integer()
  def leftmost_value(nil), do: nil
  def leftmost_value({value, nil, nil}), do: value
  def leftmost_value({_leaves, left, _right}), do: leftmost_value(left)

  @spec rightmost_value(tree()) :: integer()
  def rightmost_value(nil), do: nil
  def rightmost_value({value, nil, nil}), do: value
  def rightmost_value({_leaves, _left, right}), do: rightmost_value(right)

  @spec lookup_in_tree(tree(), non_neg_integer()) :: integer()
  def lookup_in_tree(nil, _), do: nil
  def lookup_in_tree({value, nil, nil}, 0), do: value
  def lookup_in_tree({_value, nil, nil}, _), do: nil

  def lookup_in_tree({_size, left, right}, index) do
    left_size = size_of_tree(left)

    cond do
      index < left_size ->
        lookup_in_tree(left, index)

      true ->
        lookup_in_tree(right, index - left_size)
    end
  end

  @spec update_tree(tree(), non_neg_integer(), integer()) :: tree()
  def update_tree(nil, _, _), do: nil
  def update_tree({_value, nil, nil}, 0, new_val), do: {new_val, nil, nil}
  def update_tree(leaf = {_value, nil, nil}, _, _), do: leaf

  def update_tree({total_size, left, right}, index, new_val) do
    left_size = size_of_tree(left)

    cond do
      index < left_size ->
        {total_size, update_tree(left, index, new_val), right}

      true ->
        {total_size, left, update_tree(right, index - left_size, new_val)}
    end
  end

  @spec tree_to_list(tree()) :: [integer()]
  def tree_to_list(nil), do: []
  def tree_to_list({value, nil, nil}), do: [value]
  def tree_to_list({_leaves, left, right}), do: tree_to_list(left) ++ tree_to_list(right)
end
