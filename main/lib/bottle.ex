defmodule Bottle do
  @behaviour :gen_statem

  def callback_mode, do: :handle_event_function

  def start_link(_) do
    :gen_statem.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    {:ok, :empty, []}
  end

  def handle_event({:call, from}, :get_state, state, data) do
    :gen_statem.reply(from, state)
    {:keep_state, data}
  end

  def handle_event(:cast, :fill, :empty, data) do
    {:next_state, :filled, data}
  end

  def handle_event(:cast, :empty, :full, data) do
    {:next_state, :empty, data}
  end

  def handle_event(_event_type, _request, _state, data) do
    {:keep_state, data}
  end
end
