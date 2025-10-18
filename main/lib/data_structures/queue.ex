defmodule DataStructure.Queue do
  @moduledoc """
  A simple functional queue implemented as a two-list tuple `{front, back}`.
  Enqueue adds to the back list; dequeue and head remove/peek from the front.
  """

  # --- Types -------------------------------------------------------------

  @type queue(element) :: {front :: [element], rear :: [element]}
  @type queue :: queue(any)

  # --- Construction ------------------------------------------------------

  @spec new() :: queue()
  def new, do: {[], []}

  # --- Predicates --------------------------------------------------------

  @spec empty?(queue) :: boolean()
  def empty?({[], []}), do: true
  def empty?(_), do: false

  # --- Operations --------------------------------------------------------

  @spec head(queue(element)) :: element | nil when element: term()
  def head({[], []}), do: nil
  def head({[], back}), do: List.last(back)
  def head({[head | _tail], _back}), do: head

  @spec tail(queue(element)) :: element | nil when element: term()
  def tail({[], []}), do: nil
  def tail({_, [head | _tail]}), do: head
  def tail({front, []}), do: List.last(front)

  @spec enqueue(queue(element), element) :: queue(element) when element: term()
  def enqueue({front, back}, data), do: {front, [data | back]}

  @spec enqueue_front(queue(element), element) :: queue(element) when element: term()
  def enqueue_front({front, back}, data), do: {[data | front], back}

  @spec dequeue(queue(element)) :: {:ok, element, queue(element)} | :empty when element: term()
  def dequeue({[], []}), do: :empty

  def dequeue({[], back}) do
    [head | tail] = Enum.reverse(back)
    {:ok, head, {tail, []}}
  end

  def dequeue({[head | tail], back}), do: {:ok, head, {tail, back}}

  @spec dequeue_rear(queue(element)) :: {:ok, element, queue(element)} | :empty
        when element: term()
  def dequeue_rear({[], []}), do: :empty

  def dequeue_rear({front, []}) do
    [head | tail] = Enum.reverse(front)
    {:ok, head, {[], tail}}
  end

  def dequeue_rear({front, [head | tail]}), do: {:ok, head, {front, tail}}

  @spec toList(queue(element)) :: list() when element: term()
  def toList({[], []}), do: []
  def toList({front, back}), do: front ++ Enum.reverse(back)

  @spec fromList(list(element)) :: queue(element) when element: term()
  def fromList(list), do: {list, []}
end
