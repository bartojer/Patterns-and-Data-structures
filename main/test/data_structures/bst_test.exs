defmodule DataStructure.BstTest do
  use ExUnit.Case
  alias DataStructure.Bst

  describe "new/0" do
    test "creates an empty tree" do
      assert Bst.new() == nil
    end
  end

  describe "empty/1" do
    test "returns true for nil tree" do
      assert Bst.empty(nil) == true
    end

    test "returns true for empty tuple" do
      assert Bst.empty({}) == true
    end

    test "returns true for zero-value node" do
      assert Bst.empty({0, nil, nil, nil}) == true
    end

    test "returns false for non-empty tree" do
      tree = Bst.add(nil, 5)
      assert Bst.empty(tree) == false
    end
  end

  describe "add/2" do
    test "adds element to empty tree" do
      tree = Bst.add(nil, 10)
      assert tree == {0, 10, nil, nil}
    end

    test "adds smaller element to the left" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)

      assert tree == {1, 10, {0, 5, nil, nil}, nil}
    end

    test "adds larger element to the right" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(15)

      assert tree == {1, 10, nil, {0, 15, nil, nil}}
    end

    test "adds equal element to the left" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(10)

      assert tree == {1, 10, {0, 10, nil, nil}, nil}
    end

    test "builds a balanced tree with multiple elements" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)
        |> Bst.add(3)
        |> Bst.add(7)

      assert Bst.contains?(tree, 10)
      assert Bst.contains?(tree, 5)
      assert Bst.contains?(tree, 15)
      assert Bst.contains?(tree, 3)
      assert Bst.contains?(tree, 7)
    end
  end

  describe "contains?/2" do
    test "returns false for empty tree" do
      assert Bst.contains?(nil, 10) == false
      assert Bst.contains?({}, 10) == false
    end

    test "returns true when value exists in root" do
      tree = Bst.add(nil, 10)
      assert Bst.contains?(tree, 10) == true
    end

    test "returns false when value does not exist" do
      tree = Bst.add(nil, 10)
      assert Bst.contains?(tree, 5) == false
    end

    test "finds value in left subtree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)

      assert Bst.contains?(tree, 5) == true
    end

    test "finds value in right subtree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)

      assert Bst.contains?(tree, 15) == true
    end

    test "searches deep tree structure" do
      tree =
        nil
        |> Bst.add(50)
        |> Bst.add(25)
        |> Bst.add(75)
        |> Bst.add(10)
        |> Bst.add(30)
        |> Bst.add(60)
        |> Bst.add(80)

      assert Bst.contains?(tree, 10) == true
      assert Bst.contains?(tree, 30) == true
      assert Bst.contains?(tree, 60) == true
      assert Bst.contains?(tree, 80) == true
      assert Bst.contains?(tree, 100) == false
    end
  end

  describe "remove/2" do
    test "returns nil when removing from empty tree" do
      assert Bst.remove(nil, 10) == nil
    end

    test "removes single node (leaf)" do
      tree = Bst.add(nil, 10)
      result = Bst.remove(tree, 10)
      assert result == nil
    end

    test "returns node unchanged when value not found" do
      tree = Bst.add(nil, 10)
      result = Bst.remove(tree, 5)
      assert result == {0, 10, nil, nil}
    end

    test "removes node with only right child" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(15)

      result = Bst.remove(tree, 10)
      assert result == {0, 15, nil, nil}
    end

    test "removes node with only left child" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)

      result = Bst.remove(tree, 10)
      assert result == {0, 5, nil, nil}
    end

    test "removes node with two children" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)

      result = Bst.remove(tree, 10)
      refute Bst.contains?(result, 10)
      assert Bst.contains?(result, 5)
      assert Bst.contains?(result, 15)
    end

    test "removes leaf node from left subtree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)

      result = Bst.remove(tree, 5)
      assert Bst.contains?(result, 10)
      refute Bst.contains?(result, 5)
      assert Bst.contains?(result, 15)
    end

    test "removes leaf node from right subtree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)

      result = Bst.remove(tree, 15)
      assert Bst.contains?(result, 10)
      assert Bst.contains?(result, 5)
      refute Bst.contains?(result, 15)
    end
  end

  describe "min/1" do
    test "returns error for empty tree" do
      assert Bst.min(nil) == :error
      assert Bst.min({}) == :error
    end

    test "returns value for single node tree" do
      tree = Bst.add(nil, 10)
      assert Bst.min(tree) == 10
    end

    test "finds minimum value in tree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)
        |> Bst.add(3)
        |> Bst.add(7)

      assert Bst.min(tree) == 3
    end

    test "finds minimum in left-skewed tree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(8)
        |> Bst.add(6)
        |> Bst.add(4)

      assert Bst.min(tree) == 4
    end
  end

  describe "max/1" do
    test "returns error for empty tree" do
      assert Bst.max(nil) == :error
      assert Bst.max({}) == :error
    end

    test "returns value for single node tree" do
      tree = Bst.add(nil, 10)
      assert Bst.max(tree) == 10
    end

    test "finds maximum value in tree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)
        |> Bst.add(3)
        |> Bst.add(20)

      assert Bst.max(tree) == 20
    end

    test "finds maximum in right-skewed tree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(12)
        |> Bst.add(14)
        |> Bst.add(16)

      assert Bst.max(tree) == 16
    end
  end

  describe "to_list/1" do
    test "returns empty list for empty tree" do
      assert Bst.to_list(nil) == []
      assert Bst.to_list({}) == []
    end

    test "returns error for invalid input" do
      assert Bst.to_list(:invalid) == :error
    end

    test "returns single element list for single node" do
      tree = Bst.add(nil, 10)
      assert Bst.to_list(tree) == [10]
    end

    test "returns sorted list of elements" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)
        |> Bst.add(3)
        |> Bst.add(7)
        |> Bst.add(12)
        |> Bst.add(20)

      assert Bst.to_list(tree) == [3, 5, 7, 10, 12, 15, 20]
    end

    test "handles duplicate values" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(10)
        |> Bst.add(5)

      result = Bst.to_list(tree)
      assert Enum.sort(result) == [5, 5, 10, 10]
    end
  end

  describe "from_list/1" do
    test "returns error for nil input" do
      assert Bst.from_list(nil) == :error
    end

    test "returns empty tree for empty list" do
      tree = Bst.from_list([])
      assert Bst.empty(tree)
    end

    test "creates tree from single element list" do
      tree = Bst.from_list([10])
      assert Bst.contains?(tree, 10)
    end

    test "creates tree from multiple elements" do
      tree = Bst.from_list([10, 5, 15, 3, 7, 12, 20])

      assert Bst.contains?(tree, 10)
      assert Bst.contains?(tree, 5)
      assert Bst.contains?(tree, 15)
      assert Bst.contains?(tree, 3)
      assert Bst.contains?(tree, 7)
      assert Bst.contains?(tree, 12)
      assert Bst.contains?(tree, 20)
    end

    test "round trip: list to tree to list" do
      original = [10, 5, 15, 3, 7, 12, 20]
      tree = Bst.from_list(original)
      result = Bst.to_list(tree)

      assert Enum.sort(original) == result
    end
  end

  describe "height/1" do
    test "returns nil for empty tuple" do
      assert Bst.height({}) == nil
    end

    test "returns 0 for single node" do
      tree = Bst.add(nil, 10)
      assert Bst.height(tree) == 0
    end

    test "returns correct height for small tree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)

      assert Bst.height(tree) == 1
    end

    test "returns correct height for deeper tree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)
        |> Bst.add(3)
        |> Bst.add(7)

      assert Bst.height(tree) == 2
    end
  end

  describe "is_balanced?/1" do
    test "returns true for empty tree" do
      assert Bst.is_balanced?(nil) == true
    end

    test "returns true for single node" do
      tree = Bst.add(nil, 10)
      assert Bst.is_balanced?(tree) == true
    end

    test "returns true for balanced tree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)

      assert Bst.is_balanced?(tree) == true
    end

    test "returns false for unbalanced tree with only left child at height > 0" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(3)

      refute Bst.is_balanced?(tree)
    end

    test "returns false for unbalanced tree with only right child at height > 0" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(15)
        |> Bst.add(20)

      refute Bst.is_balanced?(tree)
    end

    test "returns false when height difference exceeds 1" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(3)
        |> Bst.add(1)

      refute Bst.is_balanced?(tree)
    end

    test "returns true for perfectly balanced tree" do
      tree =
        nil
        |> Bst.add(10)
        |> Bst.add(5)
        |> Bst.add(15)
        |> Bst.add(3)
        |> Bst.add(7)
        |> Bst.add(12)
        |> Bst.add(20)

      assert Bst.is_balanced?(tree) == true
    end
  end
end
