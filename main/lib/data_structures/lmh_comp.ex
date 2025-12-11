defmodule DataStructure.LmhComp do
  @type heap :: {non_neg_integer(), integer(), heap(), heap()}

  def new(), do: nil

  def empty?(nil), do: true
  def empty?(_), do: false

  def insert(nil, element), do: {1, element, nil, nil}

  def insert(heap, element) do
    merge(heap, {1, element, nil, nil})
  end

  def find_min(nil), do: nil
  def find_min({_rank, value, _left, _right}), do: value

  def delete_min(nil), do: nil

  def delete_min({_rank, _value, l_branch, r_branch}),
    do: merge(l_branch, r_branch)

  def merge(nil, nil), do: nil
  def merge(left, nil), do: left
  def merge(nil, right), do: right

  def merge(
        _l_branch = {_lrank, l_val, l_left, l_right},
        r_branch = {_rrank, r_val, _r_left, _r_right}
      )
      when l_val <= r_val do
    merged_right = merge(l_right, r_branch)
    build_node(l_val, l_left, merged_right)
  end

  def merge(
        l_branch = {_lrank, _l_val, _l_left, _l_right},
        _r_branch = {_rrank, r_val, r_left, r_right}
      ) do
    merged_right = merge(l_branch, r_right)
    build_node(r_val, r_left, merged_right)
  end

  def to_list(nil), do: []

  def to_list(heap) do
    [find_min(heap) | to_list(delete_min(heap))]
  end

  def from_list([]), do: nil

  def from_list(numbers) do
    Enum.reduce(numbers, new(), fn number, heap -> insert(heap, number) end)
  end

  defp build_node(val, nil, nil), do: {1, val, nil, nil}
  defp build_node(val, left, nil), do: {1, val, left, nil}
  defp build_node(val, nil, right), do: {1, val, right, nil}

  defp build_node(val, left = {l_rank, _, _, _}, right = {r_rank, _, _, _})
       when l_rank >= r_rank do
    {r_rank + 1, val, left, right}
  end

  defp build_node(val, left = {l_rank, _, _, _}, right) do
    {l_rank + 1, val, right, left}
  end

  defp rank(nil), do: 0
  defp rank({rank, _, _, _}), do: rank
end
