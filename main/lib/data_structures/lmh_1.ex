defmodule LeftistMinHeap do
  @type heap :: nil | {non_neg_integer(), any(), heap(), heap()}
  # rank (dist from leaf), val, left, right

  @spec new() :: nil
  def new(), do: nil

  @spec empty?(heap) :: boolean()
  def empty?(nil), do: true
  def empty?(_), do: false

  @spec insert(heap, integer()) :: heap
  def insert(nil, element), do: {1, element, nil, nil}

  # Creates a singleton node, then merges the new node with the existing heap. This will recursively merge until it becomes a leftist min-heap
  def insert(heap, element) do
    single_heap = {1, element, nil, nil}

    merge(single_heap, heap)
  end

  # If there is a nil at either parameters, there is nothing to merge, so h is simply returned
  @spec merge(heap, heap) :: heap
  def merge(nil, nil), do: nil
  def merge(nil, right), do: right
  def merge(left, nil), do: left

  def merge(
        l_branch = {_lrank, l_val, l_left, l_right},
        r_branch = {_rrank, r_val, r_left, r_right}
      )
      when l_val <= r_val do
    merged_right = merge(l_right, r_branch)
    build_node(l_val, l_left, merged_right)
  end

  def merge(
        l_branch = {_lrank, l_val, l_left, l_right},
        r_branch = {_rrank, r_val, r_left, r_right}
      ) do
    merged_right = merge(l_branch, r_right)
    build_node(r_val, r_left, merged_right)
  end

  @spec find_min(heap) :: integer() | nil
  def find_min(nil), do: nil
  def find_min({_, value, _, _}), do: value

  # if the heap is empty, there's nothing to remove
  @spec delete_min(heap) :: heap
  def delete_min(nil), do: nil

  # Remove the root, and merge the left and right subtrees
  def delete_min({_rank, _value, l_branch, r_branch}) do
    merge(l_branch, r_branch)
  end

  @spec build_node(integer(), heap, heap) :: heap
  defp build_node(value, nil, nil), do: {1, value, nil, nil}
  defp build_node(value, left, nil), do: {rank(left) + 1, value, left, nil}
  defp build_node(value, nil, right), do: {rank(right) + 1, value, nil, right}

  defp build_node(value, left = {l_rank, _, _, _}, right = {r_rank, _, _, _})
       when l_rank >= r_rank,
       do: {r_rank + 1, value, left, right}

  defp build_node(value, left = {l_rank, _, _, _}, right = {r_rank, _, _, _})
       when l_rank < r_rank,
       do: {l_rank + 1, value, right, left}

  @spec rank(heap) :: non_neg_integer()
  def rank(nil), do: 0
  def rank({rank, _, _, _}), do: rank

  # Build a heap from a list
  @spec from_list([integer()]) :: heap
  def from_list([]), do: new()

  def from_list(numbers) do
    Enum.reduce(numbers, new(), fn number, heap -> insert(heap, number) end)
  end

  @spec to_list(heap) :: [integer()]
  def to_list(nil), do: []

  def to_list(heap) do
    [find_min(heap) | to_list(delete_min(heap))]
  end
end
