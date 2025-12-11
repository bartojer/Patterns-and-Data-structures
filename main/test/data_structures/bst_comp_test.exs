defmodule DataStructure.BstCompTest do
  use ExUnit.Case
  alias DataStructure.BstComp

  describe "new/0" do
    test "creates an empty tree" do
      assert BstComp.new() == nil
    end
  end

  describe "empty?/1" do
    test "returns true for nil" do
      assert BstComp.empty?(nil)
    end

    test "returns true for empty tuple" do
      assert BstComp.empty?({})
    end

    test "returns true for zero-height node with nil value" do
      assert BstComp.empty?({0, nil, nil, nil})
    end

    test "returns false for non-empty tree" do
      tree = BstComp.add(nil, 5)
      refute BstComp.empty?(tree)
    end
  end

  describe "add/2" do
    test "adds element to empty tree" do
      tree = BstComp.add(nil, 5)
      assert tree == {0, 5, nil, nil}
    end

    test "adds smaller element to left" do
      tree = BstComp.new() |> BstComp.add(5) |> BstComp.add(3)
      assert {1, 5, {0, 3, nil, nil}, nil} = tree
    end

    test "adds larger element to right" do
      tree = BstComp.new() |> BstComp.add(5) |> BstComp.add(7)
      assert {1, 5, nil, {0, 7, nil, nil}} = tree
    end

    test "adds equal element to left (allows duplicates)" do
      tree = BstComp.new() |> BstComp.add(5) |> BstComp.add(5)
      assert {1, 5, {0, 5, nil, nil}, nil} = tree
    end

    test "builds unbalanced tree with sequential insertions" do
      tree = BstComp.new() |> BstComp.add(1) |> BstComp.add(2) |> BstComp.add(3)
      assert BstComp.height(tree) == 2
      refute BstComp.is_balanced?(tree)
    end

    test "adds multiple elements maintaining BST property" do
      tree = BstComp.from_list([5, 3, 7, 1, 9])
      assert BstComp.to_list(tree) == [1, 3, 5, 7, 9]
    end
  end

  describe "contains?/1" do
    test "returns false for nil tree" do
      refute BstComp.contains?(nil, 5)
    end

    test "returns false for empty tuple" do
      refute BstComp.contains?({}, 5)
    end

    test "finds element in single-node tree" do
      tree = BstComp.add(nil, 5)
      assert BstComp.contains?(tree, 5)
    end

    test "returns false when element not in single-node tree" do
      tree = BstComp.add(nil, 5)
      refute BstComp.contains?(tree, 3)
    end

    test "finds element in left subtree" do
      tree = BstComp.from_list([5, 3, 7, 1])
      assert BstComp.contains?(tree, 1)
    end

    test "finds element in right subtree" do
      tree = BstComp.from_list([5, 3, 7, 9])
      assert BstComp.contains?(tree, 9)
    end

    test "returns false for non-existent element" do
      tree = BstComp.from_list([5, 3, 7])
      refute BstComp.contains?(tree, 10)
    end
  end

  describe "remove/2" do
    test "returns nil when removing from empty tree" do
      assert BstComp.remove(nil, 5) == nil
    end

    test "removes leaf node" do
      tree = BstComp.from_list([5, 3, 7])
      tree = BstComp.remove(tree, 3)
      refute BstComp.contains?(tree, 3)
      assert BstComp.contains?(tree, 5)
      assert BstComp.contains?(tree, 7)
    end

    test "removes node with only right child" do
      tree = BstComp.from_list([5, 7])
      tree = BstComp.remove(tree, 5)
      assert tree == {0, 7, nil, nil}
    end

    test "removes node with only left child" do
      tree = BstComp.from_list([5, 3])
      tree = BstComp.remove(tree, 5)
      assert tree == {0, 3, nil, nil}
    end

    test "removes node with two children" do
      tree = BstComp.from_list([5, 3, 7, 1, 4, 6, 9])
      tree = BstComp.remove(tree, 5)
      refute BstComp.contains?(tree, 5)
      assert BstComp.to_list(tree) == [1, 3, 4, 6, 7, 9]
    end

    test "does not remove non-existent element" do
      tree = BstComp.from_list([5, 3, 7])
      original_list = BstComp.to_list(tree)
      tree = BstComp.remove(tree, 10)
      assert BstComp.to_list(tree) == original_list
    end
  end

  describe "min/1" do
    test "returns :error for nil tree" do
      assert BstComp.min(nil) == :error
    end

    test "returns :error for empty tuple" do
      assert BstComp.min({}) == :error
    end

    test "returns value for single-node tree" do
      tree = BstComp.add(nil, 5)
      assert BstComp.min(tree) == 5
    end

    test "finds minimum in tree" do
      tree = BstComp.from_list([5, 3, 7, 1, 9])
      assert BstComp.min(tree) == 1
    end
  end

  describe "max/1" do
    test "returns :error for nil tree" do
      assert BstComp.max(nil) == :error
    end

    test "returns :error for empty tuple" do
      assert BstComp.max({}) == :error
    end

    test "returns value for single-node tree" do
      tree = BstComp.add(nil, 5)
      assert BstComp.max(tree) == 5
    end

    test "finds maximum in tree" do
      tree = BstComp.from_list([5, 3, 7, 1, 9])
      assert BstComp.max(tree) == 9
    end
  end

  describe "to_list/1" do
    test "returns empty list for nil tree" do
      assert BstComp.to_list(nil) == []
    end

    test "returns empty list for empty tuple" do
      assert BstComp.to_list({}) == []
    end

    test "returns single element for single-node tree" do
      tree = BstComp.add(nil, 5)
      assert BstComp.to_list(tree) == [5]
    end

    test "returns sorted list (in-order traversal)" do
      tree = BstComp.from_list([5, 3, 7, 1, 9, 4])
      assert BstComp.to_list(tree) == [1, 3, 4, 5, 7, 9]
    end

    test "handles duplicates" do
      tree = BstComp.from_list([5, 3, 5, 3])
      assert BstComp.to_list(tree) == [3, 3, 5, 5]
    end
  end

  describe "from_list/1" do
    test "creates empty tree from empty list" do
      tree = BstComp.from_list([])
      assert BstComp.empty?(tree)
    end

    test "creates tree from list" do
      tree = BstComp.from_list([5, 3, 7])
      assert BstComp.contains?(tree, 5)
      assert BstComp.contains?(tree, 3)
      assert BstComp.contains?(tree, 7)
    end

    test "maintains sorted order" do
      list = [5, 3, 7, 1, 9]
      tree = BstComp.from_list(list)
      assert BstComp.to_list(tree) == Enum.sort(list)
    end
  end

  describe "height/1" do
    test "returns 0 for nil tree" do
      assert BstComp.height(nil) == 0
    end

    test "returns 0 for empty tuple" do
      assert BstComp.height({}) == 0
    end

    test "returns 0 for single-node tree" do
      tree = BstComp.add(nil, 5)
      assert BstComp.height(tree) == 0
    end

    test "calculates height correctly" do
      tree = BstComp.from_list([5, 3, 7])
      assert BstComp.height(tree) == 1
    end

    test "calculates height for unbalanced tree" do
      tree = BstComp.from_list([1, 2, 3, 4, 5])
      assert BstComp.height(tree) == 4
    end
  end

  describe "is_balanced?/1" do
    test "returns true for nil tree" do
      assert BstComp.is_balanced?(nil)
    end

    test "returns true for single-node tree" do
      tree = BstComp.add(nil, 5)
      assert BstComp.is_balanced?(tree)
    end

    test "returns true for balanced tree" do
      tree = BstComp.from_list([5, 3, 7])
      assert BstComp.is_balanced?(tree)
    end

    test "returns false for unbalanced tree (left-heavy)" do
      tree = BstComp.from_list([5, 4, 3, 2, 1])
      refute BstComp.is_balanced?(tree)
    end

    test "returns false for unbalanced tree (right-heavy)" do
      tree = BstComp.from_list([1, 2, 3, 4, 5])
      refute BstComp.is_balanced?(tree)
    end

    test "returns false when height difference exceeds 1" do
      tree = BstComp.from_list([10, 5, 15, 3, 7, 1])
      refute BstComp.is_balanced?(tree)
    end
  end

  describe "complex scenarios" do
    test "maintains BST property after multiple operations" do
      tree =
        BstComp.new()
        |> BstComp.add(10)
        |> BstComp.add(5)
        |> BstComp.add(15)
        |> BstComp.add(3)
        |> BstComp.add(7)
        |> BstComp.remove(5)
        |> BstComp.add(6)

      list = BstComp.to_list(tree)
      assert list == Enum.sort(list)
    end

    test "handles negative numbers" do
      tree = BstComp.from_list([-5, -10, 0, 5, -3])
      assert BstComp.to_list(tree) == [-10, -5, -3, 0, 5]
    end

    test "handles large trees" do
      list = Enum.to_list(1..100)
      tree = BstComp.from_list(list)
      assert BstComp.contains?(tree, 50)
      assert BstComp.min(tree) == 1
      assert BstComp.max(tree) == 100
    end
  end
end
