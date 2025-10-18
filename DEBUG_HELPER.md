# Mix Test Debug Helper

## Debug Queue Tests

To debug the queue tests specifically, use this command in the terminal:

```bash
cd main && mix test test/data_structures/queue_test.exs --trace
```

## VS Code Debug Issues

If you're having issues with the VS Code debugger, here are some alternatives:

### Method 1: Use Terminal
1. Open a terminal in VS Code (Ctrl+`)
2. Run: `cd main && mix test test/data_structures/queue_test.exs --trace`

### Method 2: Use Test Lenses (if available)
1. Open the queue_test.exs file
2. Look for "Run Test" or "Debug Test" buttons above each test
3. Click the "Debug Test" button

### Method 3: Manual Debugging with IO.inspect
Add `IO.inspect()` calls in your code:

```elixir
# In your queue.ex file
def enqueue({front, back}, data) do
  result = {front, [data | back]}
  IO.inspect(result, label: "Enqueue result")
  result
end
```

### Method 4: Use IEx for Interactive Testing
```bash
cd main && iex -S mix
```

Then in IEx:
```elixir
alias DataStructure.Queue
queue = Queue.new()
queue = Queue.enqueue(queue, "test")
Queue.head(queue)
```