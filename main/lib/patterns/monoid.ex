defmodule Monoid do
  def identity, do: MapSet.new()
  def union(a, b), do: MapSet.union(a, b)
end
