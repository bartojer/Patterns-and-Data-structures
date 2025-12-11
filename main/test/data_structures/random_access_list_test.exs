defmodule DataStructures.RALTest do
  use ExUnit.Case
  alias DataStructures.RAL

  describe "empty/0 and empty?/1" do
    test "creates an empty RAL" do
      assert RAL.empty() == []
    end

    test "returns true for empty RAL" do
      assert RAL.empty?([]) == true
      assert RAL.empty?(RAL.empty()) == true
    end

    test "returns false for non-empty RAL" do
      ral = RAL.cons(1, RAL.empty())
      assert RAL.empty?(ral) == false
    end
  end

  describe "cons/2" do
    test "adds element to empty list" do
      ral = RAL.cons(5, RAL.empty())
      assert RAL.head(ral) == 5
    end

    test "adds multiple elements" do
      ral =
        RAL.empty()
        |> then(&RAL.cons(3, &1))
        |> then(&RAL.cons(2, &1))
        |> then(&RAL.cons(1, &1))

      assert RAL.toList(ral) == [1, 2, 3]
    end

    test "merges two size-1 trees when adding third element" do
      # First cons: [{1, nil, nil}]
      # Second cons: [{2, nil, nil}, {1, nil, nil}]
      # Third cons: should merge into [{2, {3, nil, nil}, {2, nil, nil}}]
      ral =
        RAL.empty()
        |> then(&RAL.cons(1, &1))
        |> then(&RAL.cons(2, &1))
        |> then(&RAL.cons(3, &1))

      assert RAL.toList(ral) == [3, 2, 1]
      assert RAL.head(ral) == 3
    end

    test "maintains correct order with many elements" do
      ral =
        Enum.reduce(10..1, RAL.empty(), fn x, acc ->
          RAL.cons(x, acc)
        end)

      assert RAL.toList(ral) == Enum.to_list(1..10)
    end

    test "cons creates proper tree structure" do
      ral =
        RAL.empty()
        |> then(&RAL.cons(1, &1))
        |> then(&RAL.cons(2, &1))
        |> then(&RAL.cons(3, &1))
        |> then(&RAL.cons(4, &1))

      # After 4 cons operations, we should have specific structure
      assert RAL.toList(ral) == [4, 3, 2, 1]
    end
  end

  describe "head/1" do
    test "returns nil for empty list" do
      assert RAL.head(RAL.empty()) == nil
    end

    test "returns first element of single-element list" do
      ral = RAL.cons(42, RAL.empty())
      assert RAL.head(ral) == 42
    end

    test "returns first element of multi-element list" do
      ral =
        RAL.empty()
        |> then(&RAL.cons(1, &1))
        |> then(&RAL.cons(2, &1))
        |> then(&RAL.cons(3, &1))

      assert RAL.head(ral) == 3
    end

    test "head does not modify the list" do
      ral = RAL.fromList([1, 2, 3, 4, 5])
      RAL.head(ral)
      assert RAL.toList(ral) == [1, 2, 3, 4, 5]
    end
  end

  describe "tail/1" do
    test "returns nil for empty list" do
      assert RAL.tail(RAL.empty()) == nil
    end

    test "returns last element of single-element list" do
      ral = RAL.cons(42, RAL.empty())
      assert RAL.tail(ral) == 42
    end

    test "returns last element of multi-element list" do
      ral =
        RAL.empty()
        |> then(&RAL.cons(1, &1))
        |> then(&RAL.cons(2, &1))
        |> then(&RAL.cons(3, &1))

      assert RAL.tail(ral) == 1
    end

    test "returns last element of larger list" do
      ral = RAL.fromList([1, 2, 3, 4, 5, 6, 7, 8])
      assert RAL.tail(ral) == 8
    end

    test "tail does not modify the list" do
      ral = RAL.fromList([1, 2, 3, 4, 5])
      RAL.tail(ral)
      assert RAL.toList(ral) == [1, 2, 3, 4, 5]
    end
  end

  describe "lookup/2" do
    test "returns nil for empty list" do
      assert RAL.lookup(RAL.empty(), 0) == nil
    end

    test "returns nil for negative index" do
      ral = RAL.fromList([1, 2, 3])
      assert RAL.lookup(ral, -1) == nil
    end

    test "returns nil for out-of-bounds index" do
      ral = RAL.fromList([1, 2, 3])
      assert RAL.lookup(ral, 3) == nil
      assert RAL.lookup(ral, 100) == nil
    end

    test "retrieves element at index 0" do
      ral = RAL.fromList([10, 20, 30])
      assert RAL.lookup(ral, 0) == 10
    end

    test "retrieves element at middle index" do
      ral = RAL.fromList([10, 20, 30, 40, 50])
      assert RAL.lookup(ral, 2) == 30
    end

    test "retrieves element at last index" do
      ral = RAL.fromList([10, 20, 30])
      assert RAL.lookup(ral, 2) == 30
    end

    test "retrieves all elements in order" do
      list = Enum.to_list(1..10)
      ral = RAL.fromList(list)

      for {expected, index} <- Enum.with_index(list) do
        assert RAL.lookup(ral, index) == expected
      end
    end

    test "works with power-of-2 sized lists" do
      # Test with 16 elements (perfect binary structure)
      list = Enum.to_list(1..16)
      ral = RAL.fromList(list)

      assert RAL.lookup(ral, 0) == 1
      assert RAL.lookup(ral, 5) == 6
      assert RAL.lookup(ral, 10) == 11
      assert RAL.lookup(ral, 15) == 16
    end

    test "works with non-power-of-2 sized lists" do
      list = Enum.to_list(1..13)
      ral = RAL.fromList(list)

      for {expected, index} <- Enum.with_index(list) do
        assert RAL.lookup(ral, index) == expected
      end
    end
  end

  describe "update/3" do
    test "returns empty list for empty input" do
      assert RAL.update(RAL.empty(), 0, 99) == []
    end

    test "returns unchanged list for negative index" do
      ral = RAL.fromList([1, 2, 3])
      assert RAL.toList(RAL.update(ral, -1, 99)) == [1, 2, 3]
    end

    test "returns unchanged list for out-of-bounds index" do
      ral = RAL.fromList([1, 2, 3])
      assert RAL.toList(RAL.update(ral, 5, 99)) == [1, 2, 3]
    end

    test "updates element at index 0" do
      ral = RAL.fromList([10, 20, 30])
      updated = RAL.update(ral, 0, 99)
      assert RAL.toList(updated) == [99, 20, 30]
    end

    test "updates element at middle index" do
      ral = RAL.fromList([10, 20, 30, 40, 50])
      updated = RAL.update(ral, 2, 99)
      assert RAL.toList(updated) == [10, 20, 99, 40, 50]
    end

    test "updates element at last index" do
      ral = RAL.fromList([10, 20, 30])
      updated = RAL.update(ral, 2, 99)
      assert RAL.toList(updated) == [10, 20, 99]
    end

    test "update is persistent (original unchanged)" do
      ral = RAL.fromList([1, 2, 3, 4, 5])
      updated = RAL.update(ral, 2, 99)

      assert RAL.toList(ral) == [1, 2, 3, 4, 5]
      assert RAL.toList(updated) == [1, 2, 99, 4, 5]
    end

    test "multiple updates work correctly" do
      ral = RAL.fromList([1, 2, 3, 4, 5])

      updated =
        ral
        |> RAL.update(0, 10)
        |> RAL.update(2, 30)
        |> RAL.update(4, 50)

      assert RAL.toList(updated) == [10, 2, 30, 4, 50]
    end

    test "update works on larger lists" do
      ral = RAL.fromList(Enum.to_list(1..20))
      updated = RAL.update(ral, 10, 999)
      result = RAL.toList(updated)

      assert Enum.at(result, 10) == 999
      assert Enum.at(result, 9) == 10
      assert Enum.at(result, 11) == 12
    end
  end

  describe "toList/1" do
    test "converts empty RAL to empty list" do
      assert RAL.toList(RAL.empty()) == []
    end

    test "converts single-element RAL" do
      ral = RAL.cons(42, RAL.empty())
      assert RAL.toList(ral) == [42]
    end

    test "converts multi-element RAL" do
      ral =
        RAL.empty()
        |> then(&RAL.cons(3, &1))
        |> then(&RAL.cons(2, &1))
        |> then(&RAL.cons(1, &1))

      assert RAL.toList(ral) == [1, 2, 3]
    end

    test "maintains correct order for large lists" do
      expected = Enum.to_list(1..100)
      ral = RAL.fromList(expected)
      assert RAL.toList(ral) == expected
    end
  end

  describe "fromList/1" do
    test "converts empty list to empty RAL" do
      ral = RAL.fromList([])
      assert RAL.empty?(ral)
    end

    test "converts single-element list" do
      ral = RAL.fromList([42])
      assert RAL.toList(ral) == [42]
    end

    test "converts multi-element list" do
      ral = RAL.fromList([1, 2, 3, 4, 5])
      assert RAL.toList(ral) == [1, 2, 3, 4, 5]
    end

    test "round trip: list -> RAL -> list" do
      original = Enum.to_list(1..50)
      ral = RAL.fromList(original)
      result = RAL.toList(ral)
      assert result == original
    end

    test "fromList creates proper structure for lookups" do
      list = [10, 20, 30, 40, 50]
      ral = RAL.fromList(list)

      assert RAL.lookup(ral, 0) == 10
      assert RAL.lookup(ral, 2) == 30
      assert RAL.lookup(ral, 4) == 50
    end
  end

  describe "integration and properties" do
    test "cons and lookup are consistent" do
      ral =
        RAL.empty()
        |> then(&RAL.cons(5, &1))
        |> then(&RAL.cons(4, &1))
        |> then(&RAL.cons(3, &1))
        |> then(&RAL.cons(2, &1))
        |> then(&RAL.cons(1, &1))

      assert RAL.lookup(ral, 0) == 1
      assert RAL.lookup(ral, 1) == 2
      assert RAL.lookup(ral, 2) == 3
      assert RAL.lookup(ral, 3) == 4
      assert RAL.lookup(ral, 4) == 5
    end

    test "head, tail, and lookup agree on boundaries" do
      ral = RAL.fromList([10, 20, 30, 40, 50])

      assert RAL.head(ral) == RAL.lookup(ral, 0)
      assert RAL.tail(ral) == RAL.lookup(ral, 4)
    end

    test "update preserves all other elements" do
      original_list = Enum.to_list(1..20)
      ral = RAL.fromList(original_list)
      updated = RAL.update(ral, 10, 999)

      for index <- 0..19 do
        expected = if index == 10, do: 999, else: Enum.at(original_list, index)
        assert RAL.lookup(updated, index) == expected
      end
    end

    test "multiple cons operations maintain order" do
      ral =
        Enum.reduce(1000..1, RAL.empty(), fn x, acc ->
          RAL.cons(x, acc)
        end)

      # Spot check various indices
      assert RAL.lookup(ral, 0) == 1
      assert RAL.lookup(ral, 500) == 501
      assert RAL.lookup(ral, 999) == 1000
    end

    test "stress test: many operations" do
      # Create a large RAL
      size = 100
      list = Enum.to_list(1..size)
      ral = RAL.fromList(list)

      # Verify all lookups
      for index <- 0..(size - 1) do
        assert RAL.lookup(ral, index) == index + 1
      end

      # Verify head and tail
      assert RAL.head(ral) == 1
      assert RAL.tail(ral) == size

      # Perform updates
      updated =
        Enum.reduce(0..(size - 1), ral, fn i, acc ->
          RAL.update(acc, i, i * 10)
        end)

      # Verify updates
      for index <- 0..(size - 1) do
        assert RAL.lookup(updated, index) == index * 10
      end
    end

    test "empty list operations" do
      empty = RAL.empty()

      assert RAL.empty?(empty) == true
      assert RAL.head(empty) == nil
      assert RAL.tail(empty) == nil
      assert RAL.lookup(empty, 0) == nil
      assert RAL.toList(empty) == []
      assert RAL.update(empty, 0, 99) == []
    end

    test "single element operations" do
      ral = RAL.fromList([42])

      assert RAL.empty?(ral) == false
      assert RAL.head(ral) == 42
      assert RAL.tail(ral) == 42
      assert RAL.lookup(ral, 0) == 42
      assert RAL.lookup(ral, 1) == nil
      assert RAL.toList(ral) == [42]

      updated = RAL.update(ral, 0, 99)
      assert RAL.toList(updated) == [99]
    end

    test "immutability: operations don't affect original" do
      original = RAL.fromList([1, 2, 3, 4, 5])

      # Perform various operations
      _updated = RAL.update(original, 2, 99)
      _with_cons = RAL.cons(0, original)
      _head = RAL.head(original)
      _tail = RAL.tail(original)
      _lookup = RAL.lookup(original, 3)
      _list = RAL.toList(original)

      # Original should be unchanged
      assert RAL.toList(original) == [1, 2, 3, 4, 5]
    end
  end

  describe "edge cases" do
    test "large list with power-of-2 length" do
      size = 256
      list = Enum.to_list(1..size)
      ral = RAL.fromList(list)

      assert RAL.toList(ral) == list
      assert RAL.head(ral) == 1
      assert RAL.tail(ral) == size
      assert RAL.lookup(ral, 128) == 129
    end

    test "large list with non-power-of-2 length" do
      size = 255
      list = Enum.to_list(1..size)
      ral = RAL.fromList(list)

      assert RAL.toList(ral) == list
      assert RAL.head(ral) == 1
      assert RAL.tail(ral) == size
    end

    test "cons many times creates valid structure" do
      ral = Enum.reduce(100..1, RAL.empty(), fn x, acc -> RAL.cons(x, acc) end)
      list = RAL.toList(ral)

      assert length(list) == 100
      assert list == Enum.to_list(1..100)
    end

    test "alternating cons and lookup" do
      ral = RAL.empty()

      ral = RAL.cons(1, ral)
      assert RAL.lookup(ral, 0) == 1

      ral = RAL.cons(2, ral)
      assert RAL.lookup(ral, 0) == 2
      assert RAL.lookup(ral, 1) == 1

      ral = RAL.cons(3, ral)
      assert RAL.lookup(ral, 0) == 3
      assert RAL.lookup(ral, 1) == 2
      assert RAL.lookup(ral, 2) == 1
    end
  end
end
