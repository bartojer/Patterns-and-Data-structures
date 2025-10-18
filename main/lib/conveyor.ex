defmodule Conveyor do
  @behaviour :gen_statem

  def callback_mode(), do: :handle_event_function

  def start_link(initial_count \\ 0) do
    IO.puts("Starting Conveyor...")
    :gen_statem.start_link(__MODULE__, initial_count, [])
  end

  # , name: :conveyor

  def child_spec(init_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_arg]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(initial_count) do
    {:ok, :idle, initial_count}
  end

  def handle_event({:call, from}, :get_state, state, count) do
    :gen_statem.reply(from, state)
    {:keep_state, count}
  end

  def handle_event({:call, from}, :get_count, _state, count) do
    :gen_statem.reply(from, count)
    {:keep_state, count}
  end

  def handle_event(:cast, :new_item, :idle, count) do
    {:next_state, :moving_forward, count + 1, [{:state_timeout, 10_000, :new_item_timeout}]}
  end

  def handle_event(:cast, :new_item, :moving_forward, count) do
    {:keep_state, count + 1, [{:state_timeout, 10_000, :new_item_timeout}]}
  end

  def handle_event(:state_timeout, :new_item_timeout, :moving_forward, count) do
    {:next_state, :idle, count}
  end

  def handle_event(:cast, :error, :moving_forward, count) do
    {:next_state, :paused, count}
  end

  def handle_event(:cast, :cleared, :paused, count) do
    {:next_state, :idle, count}
  end

  def handle_event(_event_type, _request, _state, count) do
    {:keep_state, count}
  end
end
