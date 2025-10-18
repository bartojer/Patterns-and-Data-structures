defmodule Traffic do
  @behaviour :gen_statem

  def callback_mode, do: :handle_event_function

  def start_link do
    :gen_statem.start_link(__MODULE__, :ok, [])
  end

  def init(_) do
    {:ok, :normal_flow, []}
  end

  def handle_event(:cast, :congestion_detected, :normal_flow, traffic) when traffic > 80 do
    IO.puts({:high_traffic, traffic})
    {:next_state, :congested, traffic}
  end

  def handle_event(:cast, :congestion_cleared, :congested, traffic) do
    {:next_state, :normal_flow, traffic}
  end

  def handle_event({:call, from}, :get_state, state, traffic) do
    :gen_statem.reply(from, state)
    {:keep_state, traffic}
  end

  def handle_event({:call, from}, :get_traffic, _state, traffic) do
    :gen_statem.reply(from, traffic)
    {:keep_state, traffic}
  end
end
