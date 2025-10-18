
defmodule Stock do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(inventory) do
    {:ok, inventory}
  end

  def handle_call(message, _from, inventory) do
    case message do
      :all ->
        {:reply, inventory, inventory}
      :next ->
        [next | _remainder] = inventory
        {:reply, next, inventory}
      :count ->
        {:reply, Enum.count(inventory), inventory}
      {:count, item} ->
        {:reply, Enum.count(inventory, &(&1 == item)), inventory}
      any ->
        {:reply, "#{any} is an invalid call", inventory}
    end
  end

  def handle_cast(request, inventory) do
    case request do
      {:add, item} when is_list(item) ->
        {:noreply, inventory ++ item}
      {:add, item} ->
        {:noreply, inventory ++ [item]}
      {:add, item, quantity} ->
        {:noreply, inventory ++ (for _ <- 1..quantity do item end)}
      {:remove, item} when is_list(item) ->
        {:noreply, inventory -- item}
        {:remove, item} ->
        {:noreply, inventory -- [item]}
      {:removeall, item} ->
        {:noreply, Enum.reject(inventory, fn x -> x == item end)} # inventory, &(&1 == item)
    end
  end
end

defmodule Calculator do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(log \\ []) do
    {:ok, log}
  end

  def handle_call(message, _from, log) do
    case message do
      {:eval, math} ->
        {answer, _bindings} = Code.eval_string(math)
        {:reply, answer, log ++ [{math, answer}]}
      :log ->
        {:reply, log, log}
    end
  end
  def handle_cast(:clear, _log) do
    {:noreply, []}
  end
end

defmodule SensorMonitor do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(log \\ %{}) do
    {:ok, log}
  end

  def handle_cast({:reading, sensor, reading}, log) when reading > 90 do
    send(sensor, {:error, reading})
    {:noreply, Map.update(log, sensor, [reading], fn readings -> [reading | readings] end)}
  end

  def handle_cast({:reading, sensor, reading}, log) do
        {:noreply, Map.update(log, sensor, [reading], fn readings -> [reading | readings] end)}
  end

  def handle_call(request, _from, log) do
    case request do
      {:last_reading, sensor} -> {:reply, Map.get(log, sensor), log}
    end
  end
end
