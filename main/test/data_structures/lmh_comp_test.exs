defmodule DataStructure.LmhCompTest do
  use ExUnit.Case
  alias DataStructure.LmhComp

  describe "new/0 and empty?/1" do
    test "creates an empty heap" do
      heap = LmhComp.new()
      assert LmhComp.empty?(heap)
    end

    test "non-empty heap returns false" do
      heap = LmhComp.insert(LmhComp.new(), 5)
      refute LmhComp.empty?(heap)
    end
  end

  describe "insert/2" do
    test "inserts into empty heap" do
      heap = LmhComp.new() |> LmhComp.insert(5)
      assert LmhComp.find_min(heap) == 5
    end

    test "inserts multiple elements and maintains min at root" do
      heap =
        LmhComp.new()
        |> LmhComp.insert(10)
        |> LmhComp.insert(5)
        |> LmhComp.insert(15)
        |> LmhComp.insert(3)

      assert LmhComp.find_min(heap) == 3
    end

    test "inserts in reverse order maintains heap property" do
      heap =
        LmhComp.new()
        |> LmhComp.insert(5)
        |> LmhComp.insert(4)
        |> LmhComp.insert(3)
        |> LmhComp.insert(2)
        |> LmhComp.insert(1)

      assert LmhComp.find_min(heap) == 1
    end
  end

  describe "find_min/1" do
    test "returns nil for empty heap" do
      assert LmhComp.find_min(LmhComp.new()) == nil
    end

    test "returns the minimum element" do
      heap =
        LmhComp.new()
        |> LmhComp.insert(20)
        |> LmhComp.insert(10)
        |> LmhComp.insert(30)

      assert LmhComp.find_min(heap) == 10
    end

    test "handles negative numbers" do
      heap =
        LmhComp.new()
        |> LmhComp.insert(5)
        |> LmhComp.insert(-10)
        |> LmhComp.insert(0)

      assert LmhComp.find_min(heap) == -10
    end
  end

  describe "delete_min/1" do
    test "returns nil for empty heap" do
      assert LmhComp.delete_min(LmhComp.new()) == nil
    end

    test "deletes minimum from single element heap" do
      heap = LmhComp.new() |> LmhComp.insert(5)
      new_heap = LmhComp.delete_min(heap)
      assert LmhComp.empty?(new_heap)
    end

    test "deletes minimum and exposes next minimum" do
      heap =
        LmhComp.new()
        |> LmhComp.insert(3)
        |> LmhComp.insert(1)
        |> LmhComp.insert(5)

      heap = LmhComp.delete_min(heap)
      assert LmhComp.find_min(heap) == 3

      heap = LmhComp.delete_min(heap)
      assert LmhComp.find_min(heap) == 5

      heap = LmhComp.delete_min(heap)
      assert LmhComp.empty?(heap)
    end
  end

  describe "merge/2" do
    test "merges two empty heaps" do
      heap1 = LmhComp.new()
      heap2 = LmhComp.new()
      merged = LmhComp.merge(heap1, heap2)
      assert LmhComp.empty?(merged)
    end

    test "merges empty heap with non-empty heap" do
      heap1 = LmhComp.new()
      heap2 = LmhComp.new() |> LmhComp.insert(5)
      merged = LmhComp.merge(heap1, heap2)
      assert LmhComp.find_min(merged) == 5
    end

    test "merges two non-empty heaps maintaining min-heap property" do
      heap1 =
        LmhComp.new()
        |> LmhComp.insert(3)
        |> LmhComp.insert(7)

      heap2 =
        LmhComp.new()
        |> LmhComp.insert(5)
        |> LmhComp.insert(9)

      merged = LmhComp.merge(heap1, heap2)
      assert LmhComp.find_min(merged) == 3
    end

    test "merge preserves all elements" do
      heap1 =
        LmhComp.new()
        |> LmhComp.insert(1)
        |> LmhComp.insert(3)

      heap2 =
        LmhComp.new()
        |> LmhComp.insert(2)
        |> LmhComp.insert(4)

      merged = LmhComp.merge(heap1, heap2)
      result = LmhComp.to_list(merged)
      assert result == [1, 2, 3, 4]
    end
  end

  describe "to_list/1" do
    test "converts empty heap to empty list" do
      assert LmhComp.to_list(LmhComp.new()) == []
    end

    test "converts heap to sorted list" do
      heap =
        LmhComp.new()
        |> LmhComp.insert(5)
        |> LmhComp.insert(2)
        |> LmhComp.insert(8)
        |> LmhComp.insert(1)
        |> LmhComp.insert(9)

      assert LmhComp.to_list(heap) == [1, 2, 5, 8, 9]
    end

    test "handles duplicate values" do
      heap =
        LmhComp.new()
        |> LmhComp.insert(5)
        |> LmhComp.insert(3)
        |> LmhComp.insert(5)
        |> LmhComp.insert(3)

      assert LmhComp.to_list(heap) == [3, 3, 5, 5]
    end
  end

  describe "from_list/1" do
    test "creates heap from empty list" do
      heap = LmhComp.from_list([])
      assert LmhComp.empty?(heap)
    end

    test "creates heap from list and maintains order" do
      heap = LmhComp.from_list([5, 2, 8, 1, 9])
      assert LmhComp.to_list(heap) == [1, 2, 5, 8, 9]
    end

    test "round trip from_list and to_list" do
      original = [7, 3, 9, 1, 5, 2, 8]
      heap = LmhComp.from_list(original)
      result = LmhComp.to_list(heap)
      assert result == Enum.sort(original)
    end
  end

  describe "leftist property" do
    test "maintains leftist property after insertions" do
      heap =
        LmhComp.new()
        |> LmhComp.insert(1)
        |> LmhComp.insert(2)
        |> LmhComp.insert(3)
        |> LmhComp.insert(4)
        |> LmhComp.insert(5)

      # Verify leftist property: left rank >= right rank
      assert verify_leftist_property(heap)
    end

    test "maintains leftist property after deletions" do
      heap = LmhComp.from_list([1, 2, 3, 4, 5, 6, 7, 8])
      heap = LmhComp.delete_min(heap)
      heap = LmhComp.delete_min(heap)

      assert verify_leftist_property(heap)
    end
  end

  describe "heap sort" do
    test "sorts a random list" do
      list = [15, 3, 9, 8, 5, 2, 12, 1, 7, 20]
      sorted = list |> LmhComp.from_list() |> LmhComp.to_list()
      assert sorted == Enum.sort(list)
    end

    test "sorts already sorted list" do
      list = [1, 2, 3, 4, 5]
      sorted = list |> LmhComp.from_list() |> LmhComp.to_list()
      assert sorted == list
    end

    test "sorts reverse sorted list" do
      list = [5, 4, 3, 2, 1]
      sorted = list |> LmhComp.from_list() |> LmhComp.to_list()
      assert sorted == [1, 2, 3, 4, 5]
    end
  end

  # Helper function to verify leftist property
  defp verify_leftist_property(nil), do: true

  defp verify_leftist_property({_rank, _val, left, right}) do
    left_rank = get_rank(left)
    right_rank = get_rank(right)

    left_rank >= right_rank and
      verify_leftist_property(left) and
      verify_leftist_property(right)
  end

  defp get_rank(nil), do: 0
  defp get_rank({rank, _val, _left, _right}), do: rank
end
