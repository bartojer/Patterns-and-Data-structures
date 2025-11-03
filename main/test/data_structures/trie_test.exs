defmodule DataStructure.TrieTest do
  use ExUnit.Case, async: true
  alias DataStructure.Trie

  doctest DataStructure.Trie

  # Test fixtures
  @test_words ["hello", "world", "help", "hell", "hero", "heroic", "test", "testing", "tester"]
  @empty_trie Trie.new()

  describe "new/0" do
    test "creates an empty trie" do
      trie = Trie.new()
      assert %Trie{end_of_word?: false, children: %{}} = trie
    end

    test "new trie contains no words" do
      trie = Trie.new()
      refute Trie.contains?(trie, "any")
      refute Trie.contains?(trie, "word")
      refute Trie.contains?(trie, "")
    end
  end

  describe "empty?/1" do
    test "returns true for new empty trie" do
      trie = Trie.new()
      assert Trie.empty?(trie)
    end

    test "returns false after adding a word" do
      trie = @empty_trie |> Trie.add("hello")
      refute Trie.empty?(trie)
    end

    test "returns false when trie contains empty string" do
      # This test will currently FAIL and reveal the bug in the current implementation
      trie = @empty_trie |> Trie.add("")
      refute Trie.empty?(trie), "Trie containing empty string should not be considered empty"
    end

    test "returns true after removing all words" do
      trie =
        @empty_trie
        |> Trie.add("hello")
        |> Trie.add("world")
        |> Trie.remove("hello")
        |> Trie.remove("world")

      assert Trie.empty?(trie)
    end

    test "returns false when trie has multiple words" do
      trie =
        @empty_trie
        |> Trie.add("hello")
        |> Trie.add("world")
        |> Trie.add("help")

      refute Trie.empty?(trie)
    end

    test "returns false after removing some but not all words" do
      trie =
        @empty_trie
        |> Trie.add("hello")
        |> Trie.add("world")
        |> Trie.remove("hello")

      refute Trie.empty?(trie)
    end

    test "returns true after adding and removing empty string" do
      trie =
        @empty_trie
        |> Trie.add("")
        |> Trie.remove("")

      assert Trie.empty?(trie)
    end

    test "returns false when only empty string remains after removing other words" do
      trie =
        @empty_trie
        |> Trie.add("")
        |> Trie.add("hello")
        |> Trie.remove("hello")

      refute Trie.empty?(trie), "Trie should not be empty when it still contains empty string"
    end

    test "handles complex add/remove scenarios correctly" do
      # Start empty
      trie = @empty_trie
      assert Trie.empty?(trie)

      # Add words with shared prefixes
      trie =
        trie
        |> Trie.add("test")
        |> Trie.add("testing")
        |> Trie.add("tester")

      refute Trie.empty?(trie)

      # Remove one word - should still not be empty
      trie = Trie.remove(trie, "testing")
      refute Trie.empty?(trie)

      # Remove remaining words - should be empty
      trie =
        trie
        |> Trie.remove("test")
        |> Trie.remove("tester")

      assert Trie.empty?(trie)
    end
  end

  describe "add/2" do
    test "adds a single word to empty trie" do
      trie = @empty_trie |> Trie.add("hello")
      assert Trie.contains?(trie, "hello")
    end

    test "adds multiple words" do
      trie =
        @empty_trie
        |> Trie.add("hello")
        |> Trie.add("world")
        |> Trie.add("help")

      assert Trie.contains?(trie, "hello")
      assert Trie.contains?(trie, "world")
      assert Trie.contains?(trie, "help")
    end

    test "adds words with common prefixes" do
      trie =
        @empty_trie
        |> Trie.add("hello")
        |> Trie.add("help")
        |> Trie.add("hell")

      assert Trie.contains?(trie, "hello")
      assert Trie.contains?(trie, "help")
      assert Trie.contains?(trie, "hell")
    end

    test "adding same word multiple times is idempotent" do
      trie1 = @empty_trie |> Trie.add("hello")
      trie2 = trie1 |> Trie.add("hello")

      assert trie1 == trie2
      assert Trie.contains?(trie2, "hello")
    end

    test "adds empty string" do
      trie = @empty_trie |> Trie.add("")
      assert Trie.contains?(trie, "")
    end

    test "adds single character words" do
      trie =
        @empty_trie
        |> Trie.add("a")
        |> Trie.add("b")
        |> Trie.add("c")

      assert Trie.contains?(trie, "a")
      assert Trie.contains?(trie, "b")
      assert Trie.contains?(trie, "c")
    end

    test "adds words with special characters" do
      trie =
        @empty_trie
        |> Trie.add("hello-world")
        |> Trie.add("test_case")
        |> Trie.add("file.txt")

      assert Trie.contains?(trie, "hello-world")
      assert Trie.contains?(trie, "test_case")
      assert Trie.contains?(trie, "file.txt")
    end

    test "adds words with unicode characters" do
      trie =
        @empty_trie
        |> Trie.add("café")
        |> Trie.add("naïve")
        |> Trie.add("résumé")

      assert Trie.contains?(trie, "café")
      assert Trie.contains?(trie, "naïve")
      assert Trie.contains?(trie, "résumé")
    end

    test "adds very long words" do
      long_word = String.duplicate("a", 1000)
      trie = @empty_trie |> Trie.add(long_word)
      assert Trie.contains?(trie, long_word)
    end
  end

  describe "contains?/2" do
    setup do
      trie = Enum.reduce(@test_words, @empty_trie, &Trie.add(&2, &1))
      %{trie: trie}
    end

    test "returns true for words that exist", %{trie: trie} do
      for word <- @test_words do
        assert Trie.contains?(trie, word), "Expected '#{word}' to be in trie"
      end
    end

    test "returns false for words that don't exist", %{trie: trie} do
      non_existent_words = ["goodbye", "hi", "tes", "testing123", "helper"]

      for word <- non_existent_words do
        refute Trie.contains?(trie, word), "Expected '#{word}' to not be in trie"
      end
    end

    test "returns false for prefixes that aren't complete words", %{trie: trie} do
      # "test" is in trie, but "tes" is not
      refute Trie.contains?(trie, "tes")

      # "hello" is in trie, but "hel" is not
      refute Trie.contains?(trie, "hel")

      # "testing" is in trie, but "testin" is not
      refute Trie.contains?(trie, "testin")
    end

    test "returns false for empty trie" do
      refute Trie.contains?(@empty_trie, "anything")
    end

    test "handles case sensitivity correctly", %{trie: trie} do
      # Assuming the trie is case-sensitive
      refute Trie.contains?(trie, "HELLO")
      refute Trie.contains?(trie, "Hello")
      refute Trie.contains?(trie, "WORLD")
    end

    test "returns true for empty string if it was added" do
      trie = @empty_trie |> Trie.add("")
      assert Trie.contains?(trie, "")
    end

    test "returns false for empty string if it wasn't added", %{trie: trie} do
      refute Trie.contains?(trie, "")
    end
  end

  describe "remove/2" do
    setup do
      trie = Enum.reduce(@test_words, @empty_trie, &Trie.add(&2, &1))
      %{trie: trie}
    end

    test "removes a word that exists", %{trie: trie} do
      updated_trie = Trie.remove(trie, "hello")

      refute Trie.contains?(updated_trie, "hello")
      # Related word should still exist
      assert Trie.contains?(updated_trie, "help")
      # Related word should still exist
      assert Trie.contains?(updated_trie, "hell")
    end

    test "removes multiple words", %{trie: trie} do
      updated_trie =
        trie
        |> Trie.remove("hello")
        |> Trie.remove("world")
        |> Trie.remove("test")

      refute Trie.contains?(updated_trie, "hello")
      refute Trie.contains?(updated_trie, "world")
      refute Trie.contains?(updated_trie, "test")

      # Other words should still exist
      assert Trie.contains?(updated_trie, "help")
      assert Trie.contains?(updated_trie, "testing")
      assert Trie.contains?(updated_trie, "tester")
    end

    test "removing non-existent word doesn't change trie", %{trie: trie} do
      updated_trie = Trie.remove(trie, "nonexistent")
      assert trie == updated_trie
    end

    test "removes word without affecting words with same prefix", %{trie: trie} do
      updated_trie = Trie.remove(trie, "testing")

      refute Trie.contains?(updated_trie, "testing")
      assert Trie.contains?(updated_trie, "test")
      assert Trie.contains?(updated_trie, "tester")
    end

    test "removes word without affecting words that have it as prefix", %{trie: trie} do
      updated_trie = Trie.remove(trie, "test")

      refute Trie.contains?(updated_trie, "test")
      assert Trie.contains?(updated_trie, "testing")
      assert Trie.contains?(updated_trie, "tester")
    end

    test "removes all words one by one", %{trie: trie} do
      final_trie = Enum.reduce(@test_words, trie, &Trie.remove(&2, &1))

      for word <- @test_words do
        refute Trie.contains?(final_trie, word)
      end
    end

    test "remove and add operations are reversible", %{trie: trie} do
      word = "hello"

      # Remove then add back
      updated_trie =
        trie
        |> Trie.remove(word)
        |> Trie.add(word)

      assert Trie.contains?(updated_trie, word)

      # The trie might not be structurally identical due to optimization,
      # but should behave the same for all words
      for test_word <- @test_words do
        assert Trie.contains?(trie, test_word) == Trie.contains?(updated_trie, test_word)
      end
    end

    test "removes empty string if it was added" do
      trie = @empty_trie |> Trie.add("")
      updated_trie = Trie.remove(trie, "")

      refute Trie.contains?(updated_trie, "")
    end

    test "removing from empty trie returns empty trie" do
      updated_trie = Trie.remove(@empty_trie, "anything")
      assert updated_trie == @empty_trie
    end
  end

  describe "prefix/2" do
    setup do
      words = [
        "hello",
        "help",
        "hell",
        "hero",
        "heroic",
        "test",
        "testing",
        "tester",
        "tea",
        "team"
      ]

      trie = Enum.reduce(words, @empty_trie, &Trie.add(&2, &1))
      %{trie: trie, words: words}
    end

    test "returns all words with given prefix", %{trie: trie} do
      # Test "he" prefix
      he_words = Trie.prefix(trie, "he")
      expected_he = ["hello", "help", "hell", "hero", "heroic"]

      assert Enum.sort(he_words) == Enum.sort(expected_he)
    end

    test "returns all words with 'test' prefix", %{trie: trie} do
      test_words = Trie.prefix(trie, "test")
      expected_test = ["test", "testing", "tester"]

      assert Enum.sort(test_words) == Enum.sort(expected_test)
    end

    test "returns single word when prefix matches exactly", %{trie: trie} do
      hello_words = Trie.prefix(trie, "hello")
      assert hello_words == ["hello"]
    end

    test "returns empty list for non-existent prefix", %{trie: trie} do
      result = Trie.prefix(trie, "xyz")
      assert result == []
    end

    test "returns empty list for prefix longer than any word", %{trie: trie} do
      result = Trie.prefix(trie, "helloworldthisisverylongprefix")
      assert result == []
    end

    test "returns all words for empty prefix", %{trie: trie, words: words} do
      all_words = Trie.prefix(trie, "")
      assert Enum.sort(all_words) == Enum.sort(words)
    end

    test "prefix search is case sensitive", %{trie: trie} do
      # Assuming case sensitivity
      result = Trie.prefix(trie, "HE")
      assert result == []
    end

    test "handles single character prefix", %{trie: trie} do
      h_words = Trie.prefix(trie, "h")
      expected_h = ["hello", "help", "hell", "hero", "heroic"]

      assert Enum.sort(h_words) == Enum.sort(expected_h)
    end

    test "handles nested prefixes correctly" do
      # Create a trie with nested words
      trie =
        @empty_trie
        |> Trie.add("a")
        |> Trie.add("ab")
        |> Trie.add("abc")
        |> Trie.add("abcd")
        |> Trie.add("abcde")

      # Test different prefix lengths
      assert Enum.sort(Trie.prefix(trie, "a")) == ["a", "ab", "abc", "abcd", "abcde"]
      assert Enum.sort(Trie.prefix(trie, "ab")) == ["ab", "abc", "abcd", "abcde"]
      assert Enum.sort(Trie.prefix(trie, "abc")) == ["abc", "abcd", "abcde"]
      assert Enum.sort(Trie.prefix(trie, "abcd")) == ["abcd", "abcde"]
      assert Trie.prefix(trie, "abcde") == ["abcde"]
      assert Trie.prefix(trie, "abcdef") == []
    end
  end

  describe "to_list/1" do
    test "returns empty list for empty trie" do
      result = Trie.to_list(@empty_trie)
      assert result == []
    end

    test "returns single word for trie with one word" do
      trie = @empty_trie |> Trie.add("hello")
      result = Trie.to_list(trie)
      assert result == ["hello"]
    end

    test "returns all words in trie" do
      words = ["hello", "world", "help", "test"]
      trie = Enum.reduce(words, @empty_trie, &Trie.add(&2, &1))
      result = Trie.to_list(trie)
      assert Enum.sort(result) == Enum.sort(words)
    end

    test "includes empty string if present" do
      trie =
        @empty_trie
        |> Trie.add("")
        |> Trie.add("hello")
        |> Trie.add("world")

      result = Trie.to_list(trie)
      expected = ["", "hello", "world"]
      assert Enum.sort(result) == Enum.sort(expected)
    end

    test "handles words with common prefixes" do
      words = ["test", "testing", "tester", "tea", "team"]
      trie = Enum.reduce(words, @empty_trie, &Trie.add(&2, &1))
      result = Trie.to_list(trie)
      assert Enum.sort(result) == Enum.sort(words)
    end

    test "returns words in deterministic order (same each time)" do
      words = ["zebra", "apple", "banana", "cherry"]
      trie = Enum.reduce(words, @empty_trie, &Trie.add(&2, &1))

      result1 = Trie.to_list(trie)
      result2 = Trie.to_list(trie)
      result3 = Trie.to_list(trie)

      assert result1 == result2
      assert result2 == result3
      assert Enum.sort(result1) == Enum.sort(words)
    end
  end

  describe "from_list/1" do
    test "creates empty trie from empty list" do
      result = Trie.from_list([])
      assert Trie.empty?(result)
      assert result == @empty_trie
    end

    test "creates trie with single word from single-item list" do
      result = Trie.from_list(["hello"])

      assert Trie.contains?(result, "hello")
      refute Trie.contains?(result, "world")
      assert Trie.to_list(result) == ["hello"]
    end

    test "creates trie from multiple words" do
      words = ["hello", "world", "help", "test"]
      result = Trie.from_list(words)

      for word <- words do
        assert Trie.contains?(result, word)
      end

      assert Enum.sort(Trie.to_list(result)) == Enum.sort(words)
    end

    test "handles empty string in list" do
      words = ["", "hello", "world"]
      result = Trie.from_list(words)

      for word <- words do
        assert Trie.contains?(result, word)
      end

      assert Enum.sort(Trie.to_list(result)) == Enum.sort(words)
    end

    test "handles duplicate words in list" do
      words_with_duplicates = ["hello", "world", "hello", "test", "world", "hello"]
      unique_words = ["hello", "world", "test"]

      result = Trie.from_list(words_with_duplicates)

      for word <- unique_words do
        assert Trie.contains?(result, word)
      end

      assert Enum.sort(Trie.to_list(result)) == Enum.sort(unique_words)
    end

    test "creates trie with words having common prefixes" do
      words = ["test", "testing", "tester", "tea", "team"]
      result = Trie.from_list(words)

      for word <- words do
        assert Trie.contains?(result, word)
      end

      # Test prefix functionality still works
      test_words = Trie.prefix(result, "test")
      assert Enum.sort(test_words) == ["test", "tester", "testing"]
    end
  end

  describe "to_list/1 and from_list/1 roundtrip" do
    test "roundtrip: from_list(to_list(trie)) == trie (functionally)" do
      original_words = ["hello", "world", "help", "test", "testing", "tester"]
      original_trie = Trie.from_list(original_words)

      # Convert to list and back to trie
      word_list = Trie.to_list(original_trie)
      roundtrip_trie = Trie.from_list(word_list)

      # Should contain same words (functionally equivalent)
      for word <- original_words do
        assert Trie.contains?(original_trie, word) == Trie.contains?(roundtrip_trie, word)
      end

      assert Enum.sort(Trie.to_list(original_trie)) == Enum.sort(Trie.to_list(roundtrip_trie))
    end

    test "roundtrip with empty trie" do
      original = @empty_trie
      word_list = Trie.to_list(original)
      roundtrip = Trie.from_list(word_list)

      assert Trie.empty?(original)
      assert Trie.empty?(roundtrip)
      assert word_list == []
    end

    test "roundtrip preserves all functionality" do
      words = ["programming", "program", "progress", "project"]
      original = Trie.from_list(words)
      roundtrip = Trie.from_list(Trie.to_list(original))

      # Test all operations work the same
      for word <- words ++ ["nonexistent", "prog"] do
        assert Trie.contains?(original, word) == Trie.contains?(roundtrip, word)
      end

      # Test prefix search works the same
      assert Enum.sort(Trie.prefix(original, "prog")) == Enum.sort(Trie.prefix(roundtrip, "prog"))

      assert Enum.sort(Trie.prefix(original, "project")) ==
               Enum.sort(Trie.prefix(roundtrip, "project"))
    end
  end

  describe "integration tests" do
    test "complex workflow with add, remove, and search operations" do
      trie = @empty_trie

      # Add words
      trie =
        trie
        |> Trie.add("programming")
        |> Trie.add("program")
        |> Trie.add("progress")
        |> Trie.add("project")
        |> Trie.add("projection")

      # Verify all words exist
      words = ["programming", "program", "progress", "project", "projection"]

      for word <- words do
        assert Trie.contains?(trie, word)
      end

      # Test prefix search
      prog_words = Trie.prefix(trie, "prog")
      assert Enum.sort(prog_words) == Enum.sort(["programming", "program", "progress"])

      proj_words = Trie.prefix(trie, "proj")
      assert Enum.sort(proj_words) == Enum.sort(["project", "projection"])

      # Remove some words
      trie =
        trie
        |> Trie.remove("programming")
        |> Trie.remove("projection")

      # Verify removals
      refute Trie.contains?(trie, "programming")
      refute Trie.contains?(trie, "projection")

      # Verify remaining words
      assert Trie.contains?(trie, "program")
      assert Trie.contains?(trie, "progress")
      assert Trie.contains?(trie, "project")

      # Test prefix search after removal
      prog_words_after = Trie.prefix(trie, "prog")
      assert Enum.sort(prog_words_after) == Enum.sort(["program", "progress"])

      proj_words_after = Trie.prefix(trie, "proj")
      assert proj_words_after == ["project"]
    end

    test "handling of edge cases" do
      trie = @empty_trie

      # Add empty string and single characters
      trie =
        trie
        |> Trie.add("")
        |> Trie.add("a")
        |> Trie.add("ab")
        |> Trie.add("b")

      assert Trie.contains?(trie, "")
      assert Trie.contains?(trie, "a")
      assert Trie.contains?(trie, "ab")
      assert Trie.contains?(trie, "b")

      # Test prefix search with empty string
      all_words = Trie.prefix(trie, "")
      assert Enum.sort(all_words) == ["", "a", "ab", "b"]

      # Remove empty string
      trie = Trie.remove(trie, "")
      refute Trie.contains?(trie, "")
      assert Trie.contains?(trie, "a")
    end

    test "performance with many words" do
      # Test with a larger dataset
      words = for i <- 1..100, do: "word_#{i}"

      # Add all words
      trie = Enum.reduce(words, @empty_trie, &Trie.add(&2, &1))

      # Verify all words exist
      for word <- words do
        assert Trie.contains?(trie, word)
      end

      # Test prefix search
      word_1_prefix = Trie.prefix(trie, "word_1")
      expected_word_1 = Enum.filter(words, &String.starts_with?(&1, "word_1"))
      assert Enum.sort(word_1_prefix) == Enum.sort(expected_word_1)

      # Remove half the words
      {to_remove, to_keep} = Enum.split(words, 50)
      trie = Enum.reduce(to_remove, trie, &Trie.remove(&2, &1))

      # Verify removals and remaining words
      for word <- to_remove do
        refute Trie.contains?(trie, word)
      end

      for word <- to_keep do
        assert Trie.contains?(trie, word)
      end
    end
  end

  describe "property-based testing helpers" do
    test "add and contains are consistent" do
      # Property: if we add a word, contains? should return true
      words = ["hello", "world", "test", "example", "elixir"]

      trie =
        Enum.reduce(words, @empty_trie, fn word, acc ->
          trie_with_word = Trie.add(acc, word)
          assert Trie.contains?(trie_with_word, word)
          trie_with_word
        end)

      # All words should still be containable in final trie
      for word <- words do
        assert Trie.contains?(trie, word)
      end
    end

    test "remove eliminates contains" do
      # Property: if we remove a word, contains? should return false
      words = ["hello", "world", "test"]
      trie = Enum.reduce(words, @empty_trie, &Trie.add(&2, &1))

      for word <- words do
        trie_without_word = Trie.remove(trie, word)
        refute Trie.contains?(trie_without_word, word)
      end
    end

    test "prefix contains all and only words with that prefix" do
      words = ["hello", "help", "world", "wonderful", "test"]
      trie = Enum.reduce(words, @empty_trie, &Trie.add(&2, &1))

      prefix = "he"
      prefix_results = Trie.prefix(trie, prefix)
      expected = Enum.filter(words, &String.starts_with?(&1, prefix))

      assert Enum.sort(prefix_results) == Enum.sort(expected)

      # Also verify that all returned words actually exist in trie
      for word <- prefix_results do
        assert Trie.contains?(trie, word)
      end
    end
  end
end
