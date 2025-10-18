defmodule DataStructure.Trie do
  # @type element :: term()
  @type node_map(element) :: %{element => trie(element)}
  @type node_map :: node_map(any)
  @type trie(element) :: {value :: element, children :: node_map(element)}
  @type trie :: trie(any)
  # @type trie(element) :: {start_node :: element, trie :: node(element)}
  # @type trie :: trie(any)
  # @type forest :: [node()]

  @spec empty?(trie) :: boolean()
  def empty?({_start_node, _other}) do
    true
  end

  @spec add(any(), trie) :: trie
  def add(word, trie) when is_binary(word) do
    add(String.to_charlist(word), trie)
  end

  def add([], {value, map}), do: {value, Map.put(map, :word_end, nil)}

  def add([next_char | remaining_chars], {value, map}) do
    if Map.has_key?(map, next_char) do
      sub_trie = Map.fetch!(map, next_char)
      updated_branch = add(remaining_chars, sub_trie)
      {value, Map.put(map, next_char, updated_branch)}
    else
      {value, Map.put(map, next_char, build_branch(remaining_chars))}
    end
  end

  @spec build_branch(list(term)) :: trie(term) | node_map(term)
  def build_branch([]), do: %{:word_end => nil}

  def build_branch([next_char | remaining_chars]) do
    {next_char, %{next_char => build_branch(remaining_chars)}}
  end

  @spec contains?(term, trie) :: boolean
  def contains?([], {_value, map}) do
    if Map.has_key?(map, :word_end) do
      true
    else
      false
    end
  end

  def contains?([next_char | remaining_chars], {_value, map}) do
    if Map.has_key?(map, next_char) do
      contains?(remaining_chars, Map.fetch!(map, next_char))
    else
      false
    end
  end
end
