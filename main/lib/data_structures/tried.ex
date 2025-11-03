defmodule DataStructure.Tried do
  @type trie(character) :: %{character => trie(character)}
  @type trie :: trie(any)

  @spec empty?(trie) :: boolean
  def empty?(%{}) do
    true
  end

  def empty?(_) do
    false
  end

  @spec add(any(), trie) :: trie
  def add(word, trie) when is_binary(word) do
    add(String.to_charlist(word), trie)
  end

  def add([], map), do: Map.put(map, :word_end, nil)

  def add([next_char | remaining_chars], map) do
    case Map.has_key?(map, next_char) do
      true ->
        sub_trie = Map.fetch!(map, next_char)
        updated_branch = add(remaining_chars, sub_trie)
        Map.put(map, next_char, updated_branch)

      false ->
        Map.put(map, next_char, build_branch(remaining_chars))
    end
  end

  @spec build_branch(list(term)) :: trie(term)
  def build_branch([]), do: %{:word_end => nil}

  def build_branch([next_char | remaining_chars]) do
    %{next_char => build_branch(remaining_chars)}
  end

  @spec contains?(term, trie) :: boolean
  def contains?([], map) do
    Map.has_key?(map, :word_end)
  end

  def contains?([next_char | remaining_chars], map) do
    case Map.has_key?(map, next_char) do
      true ->
        contains?(remaining_chars, Map.fetch!(map, next_char))

      false ->
        false
    end
  end

  @spec remove(term, trie) :: trie
  def remove(word, trie) when is_binary(word) do
    remove(String.to_charlist(word), trie)
  end

  def remove([], trie) do
    trie
  end

  def remove([first | rest], map) do
    case Map.has_key?(map, first) do
      true ->
        new_map = remove(rest, Map.fetch!(map, first))
        Map.delete(new_map, first)

      false ->
        map
    end
  end

  def find([], :word_end) do
    :word_found
  end

  def find([], trie) do
    case Map.has_key?(trie, :word_end) do
      true ->
        :word_found

      false ->
        :not_found
    end
  end

  def find([next_char | rest], trie) do
    case Map.has_key?(trie, next_char) do
      true ->
        find(rest, trie)

      false ->
        :not_found
    end
  end

  def prefix(word, map) when is_binary(word) do
    prefix_as_list = String.to_charlist(word)
    traverse_to_prefix(prefix_as_list, prefix_as_list, map)
  end

  defp traverse_to_prefix([next_char | rest], prefix, map) do
    {:ok, sub_map} = Map.fetch(map, next_char)
    traverse_to_prefix(rest, prefix, sub_map)
  end

  defp traverse_to_prefix([], prefix, map) do
    Enum.map(get_word(map, []), fn suffix ->
      prefix <> suffix
    end)
  end

  def get_word(%{word_end: nil} = map, accumulator) when map_size(map) == 1 do
    [Enum.reverse(accumulator) |> to_string()]
  end

  def get_word(map, accumulator) do
    Enum.flat_map(map, fn
      {:word_end, _} ->
        [to_string(Enum.reverse(accumulator))]

      {character, children} ->
        get_word(children, [character | accumulator])
    end)
  end
end
