defmodule DataStructure.Trie do
  @moduledoc """
  A clean Trie implementation supporting add, contains?, remove, and prefix lookup.
  """

  defstruct end_of_word?: false, children: %{}

  @type trie :: %__MODULE__{
          end_of_word?: boolean,
          children: %{optional(char) => trie}
        }

  # -- Public API --

  @spec new() :: trie
  def new(), do: %__MODULE__{}

  @spec add(trie, binary) :: trie
  def add(trie, word) when is_binary(word) do
    add_chars(trie, String.to_charlist(word))
  end

  @spec empty?(trie) :: boolean
  def empty?(%__MODULE__{end_of_word?: end_of_word, children: kids}) do
    not end_of_word and kids == %{}
  end

  @spec contains?(trie, binary) :: boolean
  def contains?(trie, word) when is_binary(word) do
    contains_chars?(trie, String.to_charlist(word))
  end

  @spec remove(trie, binary) :: trie
  def remove(trie, word) when is_binary(word) do
    {trie, _deleted?} = remove_chars(trie, String.to_charlist(word))
    trie
  end

  @spec prefix(trie, binary) :: [binary]
  def prefix(trie, word) when is_binary(word) do
    chars = String.to_charlist(word)

    case walk(trie, chars) do
      {:ok, node} -> collect_words(node, word)
      :error -> []
    end
  end

  @spec to_list(trie) :: [binary]
  def to_list(%__MODULE__{} = trie) do
    prefix(trie, "")
  end

  @spec from_list([binary]) :: trie
  def from_list([]), do: new()

  def from_list(word_list) when is_list(word_list) do
    Enum.reduce(word_list, new(), fn word, trie -> add(trie, word) end)
  end

  # -- Internal Implementation --

  defp add_chars(%__MODULE__{} = node, []), do: %{node | end_of_word?: true}

  defp add_chars(%__MODULE__{children: kids} = node, [char | rest]) do
    child = Map.get(kids, char, new())
    updated_child = add_chars(child, rest)
    %{node | children: Map.put(kids, char, updated_child)}
  end

  defp contains_chars?(%__MODULE__{end_of_word?: true}, []), do: true
  defp contains_chars?(%__MODULE__{}, []), do: false

  defp contains_chars?(%__MODULE__{children: kids}, [char | rest]) do
    case Map.get(kids, char) do
      nil -> false
      child -> contains_chars?(child, rest)
    end
  end

  # remove returns `{updated_node, should_delete_this_node?}`
  defp remove_chars(%__MODULE__{} = node, []),
    do: {%{node | end_of_word?: false}, node.children == %{}}

  defp remove_chars(%__MODULE__{children: kids} = node, [char | rest]) do
    with child when not is_nil(child) <- Map.get(kids, char),
         {new_child, delete?} <- remove_chars(child, rest) do
      new_children =
        case delete? do
          true -> Map.delete(kids, char)
          false -> Map.put(kids, char, new_child)
        end

      new_node = %{node | children: new_children}
      delete_node? = not new_node.end_of_word? and new_node.children == %{}
      {new_node, delete_node?}
    else
      _ -> {node, false}
    end
  end

  defp walk(node, []), do: {:ok, node}

  defp walk(%__MODULE__{children: kids}, [char | rest]) do
    case Map.get(kids, char) do
      nil -> :error
      child -> walk(child, rest)
    end
  end

  defp collect_words(%__MODULE__{end_of_word?: end_of_word, children: kids}, prefix) do
    base = if end_of_word, do: [prefix], else: []

    Enum.flat_map(kids, fn {char, child} ->
      collect_words(child, prefix <> <<char>>)
    end) ++ base
  end
end
