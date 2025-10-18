defmodule DataStructure.QueueTest do
  use ExUnit.Case
  doctest DataStructure.Queue

  alias DataStructure.Queue

  describe "new/0" do
    test "creates an empty queue" do
      queue = Queue.new()
      assert queue == {[], []}
      assert Queue.empty?(queue)
    end
  end

  describe "empty?/1" do
    test "returns true for empty queue" do
      assert Queue.empty?(Queue.new())
      assert Queue.empty?({[], []})
    end

    test "returns false for non-empty queue" do
      refute Queue.empty?({[1], []})
      refute Queue.empty?({[], [1]})
      refute Queue.empty?({[1], [2]})
    end
  end

  describe "enqueue/2" do
    test "adds element to empty queue" do
      queue = Queue.new()
      result = Queue.enqueue(queue, 42)
      assert result == {[], [42]}
      refute Queue.empty?(result)
    end

    test "adds element to non-empty queue" do
      queue = {[1, 2], [3]}
      result = Queue.enqueue(queue, 4)
      assert result == {[1, 2], [4, 3]}
    end

    test "can enqueue multiple elements" do
      queue =
        Queue.new()
        |> Queue.enqueue(1)
        |> Queue.enqueue(2)
        |> Queue.enqueue(3)

      assert queue == {[], [3, 2, 1]}
    end
  end

  describe "enqueue_front/2" do
    test "adds element to front of empty queue" do
      queue = Queue.new()
      result = Queue.enqueue_front(queue, 42)
      assert result == {[42], []}
      refute Queue.empty?(result)
    end

    test "adds element to front of non-empty queue" do
      queue = {[1, 2], [3]}
      result = Queue.enqueue_front(queue, 0)
      assert result == {[0, 1, 2], [3]}
    end

    test "enqueue_front puts element at head position" do
      queue =
        Queue.new()
        |> Queue.enqueue(1)
        |> Queue.enqueue_front(0)

      assert Queue.head(queue) == 0
    end
  end

  describe "head/1" do
    test "returns nil for empty queue" do
      assert Queue.head(Queue.new()) == nil
      assert Queue.head({[], []}) == nil
    end

    test "returns first element when front is not empty" do
      queue = {[1, 2, 3], [4, 5]}
      assert Queue.head(queue) == 1
    end

    test "returns last element of back when front is empty" do
      queue = {[], [1, 2, 3]}
      assert Queue.head(queue) == 3
    end
  end

  describe "tail/1" do
    test "returns nil for empty queue" do
      assert Queue.tail(Queue.new()) == nil
      assert Queue.tail({[], []}) == nil
    end

    test "returns first element of back when back has multiple elements" do
      queue = {[1, 2], [3, 4]}
      assert Queue.tail(queue) == 3
    end

    test "returns last element of front when back is empty" do
      queue = {[1, 2, 3], []}
      assert Queue.tail(queue) == 3
    end

    test "returns single element in back" do
      queue = {[1, 2], [3]}
      assert Queue.tail(queue) == 3
    end
  end

  describe "dequeue/1" do
    test "returns :empty for empty queue" do
      assert Queue.dequeue(Queue.new()) == :empty
      assert Queue.dequeue({[], []}) == :empty
    end

    test "dequeues from front when front is not empty" do
      queue = {[1, 2, 3], [4, 5]}
      assert Queue.dequeue(queue) == {:ok, 1, {[2, 3], [4, 5]}}
    end

    test "dequeues from back when front is empty" do
      queue = {[], [1, 2, 3]}
      assert Queue.dequeue(queue) == {:ok, 3, {[2, 1], []}}
    end

    test "can dequeue until empty" do
      queue =
        Queue.new()
        |> Queue.enqueue(1)
        |> Queue.enqueue(2)

      {:ok, first, queue1} = Queue.dequeue(queue)
      assert first == 1

      {:ok, second, queue2} = Queue.dequeue(queue1)
      assert second == 2

      assert Queue.dequeue(queue2) == :empty
      assert Queue.empty?(queue2)
    end
  end

  describe "dequeue_rear/1" do
    test "returns :empty for empty queue" do
      assert Queue.dequeue_rear(Queue.new()) == :empty
      assert Queue.dequeue_rear({[], []}) == :empty
    end

    test "dequeues from back when back is not empty" do
      queue = {[1, 2], [3, 4]}
      assert Queue.dequeue_rear(queue) == {:ok, 3, {[1, 2], [4]}}
    end

    test "dequeues from front when back is empty" do
      queue = {[1, 2, 3], []}
      assert Queue.dequeue_rear(queue) == {:ok, 3, {[], [2, 1]}}
    end

    test "dequeues single element from back" do
      queue = {[1, 2], [3]}
      assert Queue.dequeue_rear(queue) == {:ok, 3, {[1, 2], []}}
    end

    test "dequeues single element from front when back is empty" do
      queue = {[1], []}
      assert Queue.dequeue_rear(queue) == {:ok, 1, {[], []}}
    end
  end

  describe "toList/1" do
    test "returns empty list for empty queue" do
      assert Queue.toList(Queue.new()) == []
      assert Queue.toList({[], []}) == []
    end

    test "converts queue to list maintaining FIFO order" do
      # Queue with elements in front
      queue1 = {[1, 2, 3], []}
      assert Queue.toList(queue1) == [1, 2, 3]

      # Queue with elements in back
      queue2 = {[], [1, 2, 3]}
      assert Queue.toList(queue2) == [3, 2, 1]

      # Queue with elements in both front and back
      queue3 = {[1, 2], [3, 4]}
      assert Queue.toList(queue3) == [1, 2, 4, 3]
    end
  end

  describe "fromList/1" do
    test "creates queue from empty list" do
      queue = Queue.fromList([])
      assert queue == {[], []}
      assert Queue.empty?(queue)
    end

    test "creates queue from non-empty list" do
      queue = Queue.fromList([1, 2, 3])
      assert queue == {[1, 2, 3], []}
      assert Queue.toList(queue) == [1, 2, 3]
    end
  end

  describe "deque operations integration" do
    test "enqueue_front and dequeue work together" do
      queue =
        Queue.new()
        |> Queue.enqueue_front(1)
        |> Queue.enqueue_front(2)

      {:ok, first, queue1} = Queue.dequeue(queue)
      assert first == 2

      {:ok, second, queue2} = Queue.dequeue(queue1)
      assert second == 1

      assert Queue.empty?(queue2)
    end

    test "enqueue and dequeue_rear work together" do
      queue =
        Queue.new()
        |> Queue.enqueue(1)
        |> Queue.enqueue(2)

      {:ok, last, queue1} = Queue.dequeue_rear(queue)
      assert last == 2

      {:ok, first, queue2} = Queue.dequeue_rear(queue1)
      assert first == 1

      assert Queue.empty?(queue2)
    end

    test "mixed deque operations maintain correctness" do
      queue =
        Queue.new()
        |> Queue.enqueue(2)
        |> Queue.enqueue(3)
        |> Queue.enqueue_front(1)
        |> Queue.enqueue(4)

      # Queue should be: [1, 2, 3, 4] in FIFO order
      assert Queue.toList(queue) == [1, 2, 3, 4]

      # Dequeue from front
      {:ok, first, queue1} = Queue.dequeue(queue)
      assert first == 1

      # Dequeue from rear
      {:ok, last, queue2} = Queue.dequeue_rear(queue1)
      assert last == 4

      # Remaining should be [2, 3]
      assert Queue.toList(queue2) == [2, 3]
    end
  end

  describe "integration tests" do
    test "FIFO behavior is maintained" do
      queue =
        Queue.new()
        |> Queue.enqueue("first")
        |> Queue.enqueue("second")
        |> Queue.enqueue("third")

      {:ok, first, queue1} = Queue.dequeue(queue)
      assert first == "first"

      {:ok, second, queue2} = Queue.dequeue(queue1)
      assert second == "second"

      {:ok, third, queue3} = Queue.dequeue(queue2)
      assert third == "third"

      assert Queue.empty?(queue3)
    end

    test "fromList and toList are inverse operations" do
      original_list = [1, 2, 3, 4, 5]
      queue = Queue.fromList(original_list)
      result_list = Queue.toList(queue)

      assert result_list == original_list
    end

    test "complex queue operations maintain correctness" do
      # Start with a list
      queue = Queue.fromList([1, 2, 3])

      # Add some elements
      queue =
        queue
        |> Queue.enqueue(4)
        |> Queue.enqueue(5)

      # Remove some elements
      {:ok, first, queue} = Queue.dequeue(queue)
      {:ok, second, queue} = Queue.dequeue(queue)

      # Add more elements
      queue =
        queue
        |> Queue.enqueue(6)
        |> Queue.enqueue(7)

      # Verify the final state
      final_list = Queue.toList(queue)
      assert final_list == [3, 4, 5, 6, 7]

      # Verify we removed the correct elements
      assert first == 1
      assert second == 2
    end
  end

  describe "edge cases and error handling" do
    test "operations don't modify the original queue structure" do
      original_queue = {[1, 2], [3, 4]}

      Queue.head(original_queue)
      Queue.tail(original_queue)

      # Queue should remain unchanged
      assert original_queue == {[1, 2], [3, 4]}
    end

    test "works with different data types" do
      queue =
        Queue.new()
        |> Queue.enqueue("string")
        |> Queue.enqueue(42)
        |> Queue.enqueue(:atom)
        |> Queue.enqueue([1, 2, 3])

      {:ok, first, queue} = Queue.dequeue(queue)
      assert first == "string"

      {:ok, second, queue} = Queue.dequeue(queue)
      assert second == 42

      {:ok, third, queue} = Queue.dequeue(queue)
      assert third == :atom

      {:ok, fourth, _queue} = Queue.dequeue(queue)
      assert fourth == [1, 2, 3]
    end

    test "handles single element queues correctly" do
      # Single element in front
      queue1 = {[42], []}
      assert Queue.head(queue1) == 42
      assert Queue.tail(queue1) == 42
      {:ok, element, empty_queue} = Queue.dequeue(queue1)
      assert element == 42
      assert Queue.empty?(empty_queue)

      # Single element in back
      queue2 = {[], [42]}
      assert Queue.head(queue2) == 42
      assert Queue.tail(queue2) == 42
      {:ok, element, empty_queue} = Queue.dequeue_rear(queue2)
      assert element == 42
      assert Queue.empty?(empty_queue)
    end

    test "handles large queues efficiently" do
      # Create a large queue
      large_list = Enum.to_list(1..1000)
      queue = Queue.fromList(large_list)

      # Verify it converts back correctly
      assert Queue.toList(queue) == large_list

      # Verify we can dequeue all elements in order
      {final_queue, dequeued} =
        Enum.reduce(1..1000, {queue, []}, fn _i, {q, acc} ->
          {:ok, element, new_q} = Queue.dequeue(q)
          {new_q, [element | acc]}
        end)

      assert Queue.empty?(final_queue)
      assert Enum.reverse(dequeued) == large_list
    end
  end
end
