defmodule DataStructures.RalCompTest do
  use ExUnit.Case
  doctest DataStructures.RalComp

  alias DataStructures.RalComp

  describe "new/0" do
    test "creates an empty random access list" do
      ral = RalComp.new()
      assert ral == []
      assert RalComp.empty?(ral)
    end
  end

  describe "empty?/1" do
    test "returns true for empty list" do
      assert RalComp.empty?(RalComp.new())
      assert RalComp.empty?([])
    end

    test "returns false for non-empty list" do
      refute RalComp.empty?(RalComp.cons(RalComp.new(), 1))
      refute RalComp.empty?(RalComp.from_list([1, 2, 3]))
    end
  end

  describe "cons/2" do
    test "adds element to empty list" do
      ral = RalComp.new()
      result = RalComp.cons(ral, 42)
      refute RalComp.empty?(result)
      assert RalComp.head(result) == 42
    end

    test "adds element to non-empty list" do
      ral = RalComp.from_list([1, 2, 3])
      result = RalComp.cons(ral, 0)
      assert RalComp.head(result) == 0
    end

    test "can cons multiple elements" do
      ral =
        RalComp.new()
        |> RalComp.cons(3)
        |> RalComp.cons(2)
        |> RalComp.cons(1)

      assert RalComp.head(ral) == 1
      assert RalComp.to_list(ral) == [1, 2, 3]
    end

    test "maintains list integrity with many cons operations" do
      ral =
        Enum.reduce(10..1, RalComp.new(), fn i, acc ->
          RalComp.cons(acc, i)
        end)

      assert RalComp.to_list(ral) == Enum.to_list(1..10)
    end
  end

  describe "head/1" do
    test "returns nil for empty list" do
      assert RalComp.head(RalComp.new()) == nil
    end

    test "returns first element of non-empty list" do
      ral = RalComp.from_list([1, 2, 3])
      assert RalComp.head(ral) == 1
    end

    test "returns the most recently consed element" do
      ral =
        RalComp.new()
        |> RalComp.cons(1)
        |> RalComp.cons(2)
        |> RalComp.cons(3)

      assert RalComp.head(ral) == 3
    end
  end

  describe "tail/1" do
    test "returns nil for empty list" do
      assert RalComp.tail(RalComp.new()) == nil
    end

    test "returns last element of non-empty list" do
      ral = RalComp.from_list([1, 2, 3])
      assert RalComp.tail(ral) == 3
    end

    test "returns correct tail for single element" do
      ral = RalComp.cons(RalComp.new(), 42)
      assert RalComp.tail(ral) == 42
    end

    test "returns correct tail after multiple operations" do
      ral =
        RalComp.new()
        |> RalComp.cons(1)
        |> RalComp.cons(2)
        |> RalComp.cons(3)

      assert RalComp.tail(ral) == 1
    end
  end

  describe "lookup/2" do
    test "returns nil for empty list" do
      assert RalComp.lookup(RalComp.new(), 0) == nil
    end

    test "returns nil for negative index" do
      ral = RalComp.from_list([1, 2, 3])
      assert RalComp.lookup(ral, -1) == nil
    end

    test "returns nil for out of bounds index" do
      ral = RalComp.from_list([1, 2, 3])
      assert RalComp.lookup(ral, 10) == nil
    end

    test "returns element at index 0" do
      ral = RalComp.from_list([1, 2, 3])
      assert RalComp.lookup(ral, 0) == 1
    end

    test "returns element at middle index" do
      ral = RalComp.from_list([1, 2, 3, 4, 5])
      assert RalComp.lookup(ral, 2) == 3
    end

    test "returns element at last valid index" do
      ral = RalComp.from_list([1, 2, 3])
      assert RalComp.lookup(ral, 2) == 3
    end

    test "works with larger lists" do
      ral = RalComp.from_list(Enum.to_list(0..99))

      assert RalComp.lookup(ral, 0) == 0
      assert RalComp.lookup(ral, 50) == 50
      assert RalComp.lookup(ral, 99) == 99
    end

    test "returns correct elements for various indices" do
      ral = RalComp.from_list([10, 20, 30, 40, 50])

      assert RalComp.lookup(ral, 0) == 10
      assert RalComp.lookup(ral, 1) == 20
      assert RalComp.lookup(ral, 2) == 30
      assert RalComp.lookup(ral, 3) == 40
      assert RalComp.lookup(ral, 4) == 50
    end
  end

  describe "update/3" do
    test "returns empty list when updating empty list" do
      assert RalComp.update(RalComp.new(), 0, 42) == []
    end

    test "returns unchanged list for negative index" do
      ral = RalComp.from_list([1, 2, 3])
      assert RalComp.update(ral, -1, 99) == ral
    end

    test "returns unchanged list for out of bounds index" do
      ral = RalComp.from_list([1, 2, 3])
      result = RalComp.update(ral, 10, 99)
      assert RalComp.to_list(result) == [1, 2, 3]
    end

    test "updates element at index 0" do
      ral = RalComp.from_list([1, 2, 3])
      result = RalComp.update(ral, 0, 99)
      assert RalComp.lookup(result, 0) == 99
      assert RalComp.lookup(result, 1) == 2
      assert RalComp.lookup(result, 2) == 3
    end

    test "updates element at middle index" do
      ral = RalComp.from_list([1, 2, 3, 4, 5])
      result = RalComp.update(ral, 2, 99)
      assert RalComp.to_list(result) == [1, 2, 99, 4, 5]
    end

    test "updates element at last valid index" do
      ral = RalComp.from_list([1, 2, 3])
      result = RalComp.update(ral, 2, 99)
      assert RalComp.lookup(result, 2) == 99
    end

    test "can update multiple times" do
      ral = RalComp.from_list([1, 2, 3, 4, 5])
      result =
        ral
        |> RalComp.update(0, 10)
        |> RalComp.update(2, 30)
        |> RalComp.update(4, 50)

      assert RalComp.to_list(result) == [10, 2, 30, 4, 50]
    end

    test "works with larger lists" do
      ral = RalComp.from_list(Enum.to_list(0..99))
      result = RalComp.update(ral, 50, 999)
      assert RalComp.lookup(result, 50) == 999
      assert RalComp.lookup(result, 49) == 49
      assert RalComp.lookup(result, 51) == 51
    end
  end

  describe "to_list/1" do
    test "converts empty ral to empty list" do
      assert RalComp.to_list(RalComp.new()) == []
    end

    test "converts single element ral to list" do
      ral = RalComp.cons(RalComp.new(), 42)
      assert RalComp.to_list(ral) == [42]
    end

    test "converts multiple element ral to list" do
      ral = RalComp.from_list([1, 2, 3, 4, 5])
      assert RalComp.to_list(ral) == [1, 2, 3, 4, 5]
    end

    test "maintains order after cons operations" do
      ral =
        RalComp.new()
        |> RalComp.cons(3)
        |> RalComp.cons(2)
        |> RalComp.cons(1)

      assert RalComp.to_list(ral) == [1, 2, 3]
    end

    test "works with larger lists" do
      list = Enum.to_list(1..100)
      ral = RalComp.from_list(list)
      assert RalComp.to_list(ral) == list
    end
  end

  describe "from_list/1" do
    test "creates empty ral from empty list" do
      ral = RalComp.from_list([])
      assert RalComp.empty?(ral)
    end

    test "creates ral from single element list" do
      ral = RalComp.from_list([42])
      assert RalComp.head(ral) == 42
      assert RalComp.tail(ral) == 42
    end

    test "creates ral from multiple element list" do
      ral = RalComp.from_list([1, 2, 3, 4, 5])
      assert RalComp.to_list(ral) == [1, 2, 3, 4, 5]
    end

    test "maintains element order" do
      list = [10, 20, 30, 40, 50]
      ral = RalComp.from_list(list)
      assert RalComp.to_list(ral) == list
    end

    test "works with larger lists" do
      list = Enum.to_list(1..1000)
      ral = RalComp.from_list(list)
      assert RalComp.to_list(ral) == list
    end
  end

  describe "integration tests" do
    test "from_list and to_list are inverses" do
      list = [1, 2, 3, 4, 5]
      assert list |> RalComp.from_list() |> RalComp.to_list() == list
    end

    test "can perform mixed operations" do
      ral =
        RalComp.new()
        |> RalComp.cons(5)
        |> RalComp.cons(4)
        |> RalComp.cons(3)
        |> RalComp.cons(2)
        |> RalComp.cons(1)

      assert RalComp.head(ral) == 1
      assert RalComp.tail(ral) == 5
      assert RalComp.lookup(ral, 2) == 3

      updated = RalComp.update(ral, 2, 99)
      assert RalComp.to_list(updated) == [1, 2, 99, 4, 5]
    end

    test "lookup after update returns new value" do
      ral = RalComp.from_list([1, 2, 3, 4, 5])
      updated = RalComp.update(ral, 2, 99)
      assert RalComp.lookup(updated, 2) == 99
    end

    test "stress test with many operations" do
      # Build a large list
      ral = RalComp.from_list(Enum.to_list(1..100))

      # Verify lookups
      assert RalComp.lookup(ral, 0) == 1
      assert RalComp.lookup(ral, 49) == 50
      assert RalComp.lookup(ral, 99) == 100

      # Update multiple positions
      updated =
        ral
        |> RalComp.update(0, 1000)
        |> RalComp.update(50, 2000)
        |> RalComp.update(99, 3000)

      # Verify updates
      assert RalComp.lookup(updated, 0) == 1000
      assert RalComp.lookup(updated, 50) == 2000
      assert RalComp.lookup(updated, 99) == 3000

      # Verify unchanged elements
      assert RalComp.lookup(updated, 1) == 2
      assert RalComp.lookup(updated, 49) == 50
      assert RalComp.lookup(updated, 98) == 99
    end

    test "handles power of 2 sizes efficiently" do
      # Test sizes that align with tree structure
      for size <- [1, 2, 4, 8, 16, 32, 64] do
        list = Enum.to_list(1..size)
        ral = RalComp.from_list(list)
        assert RalComp.to_list(ral) == list
        assert RalComp.head(ral) == 1
        assert RalComp.tail(ral) == size
      end
    end

    test "handles non-power of 2 sizes" do
      for size <- [3, 5, 7, 10, 15, 20, 50] do
        list = Enum.to_list(1..size)
        ral = RalComp.from_list(list)
        assert RalComp.to_list(ral) == list
      end
    end
  end

  describe "edge cases" do
    test "single element operations" do
      ral = RalComp.from_list([42])
      assert RalComp.head(ral) == 42
      assert RalComp.tail(ral) == 42
      assert RalComp.lookup(ral, 0) == 42
      assert RalComp.lookup(ral, 1) == nil
      
      updated = RalComp.update(ral, 0, 99)
      assert RalComp.lookup(updated, 0) == 99
    end

    test "two element operations" do
      ral = RalComp.from_list([1, 2])
      assert RalComp.head(ral) == 1
      assert RalComp.tail(ral) == 2
      assert RalComp.lookup(ral, 0) == 1
      assert RalComp.lookup(ral, 1) == 2
    end

    test "handles zero values" do
      ral = RalComp.from_list([0, 0, 0])
      assert RalComp.to_list(ral) == [0, 0, 0]
      assert RalComp.lookup(ral, 1) == 0
    end

    test "handles negative values" do
      ral = RalComp.from_list([-5, -10, -15])
      assert RalComp.to_list(ral) == [-5, -10, -15]
      assert RalComp.lookup(ral, 1) == -10
    end
  end
end
