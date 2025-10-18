defmodule TrafficLight do
  @behaviour :gen_statem

  def callback_mode, do: :handle_event_function

  ## Public API
  def start_link(_) do
    :gen_statem.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    {:ok, :red, []}
  end

  def handle_event({:call, from}, :get_state, state, data) do
    :gen_statem.reply(from, state)
    {:keep_state, state, data}
  end

  def handle_event({:call, from}, :change, :red, data) do
    :gen_statem.reply(from, :changed_to_green)
    {:next_state, :green, data}
  end

  def handle_event({:call, from}, :change, :yellow, data) do
    :gen_statem.reply(from, :changed_to_red)
    {:next_state, :red, data}
  end

  def handle_event({:call, from}, :change, :green, data) do
    :gen_statem.reply(from, :changed_to_yellow)
    {:next_state, :yellow, data}
  end

  def handle_event(_event_type, _request, _state, data) do
    {:keep_state, data}
  end

end


# def callback_mode, do: :state_functions

# def change(pid) do
#   :gen_statem.call(pid, :change)
# end

# def state(pid) do
#   :gen_statem.call(pid, :get_state)
# end

# ## Callbacks
# def init(:ok) do
#   {:ok, :red, %{}}
# end

# def red({:call, from}, :change, data) do
#   :gen_statem.reply(from, :switched_to_green)
#   {:next_state, :green, data}
# end

# def red(_event_type, _event_content, data) do
#   {:keep_state, data}
# end

# def yellow({:call, from}, :change, data) do
#   :gen_statem.reply(from, :switched_to_red)
#   {:next_state, :red, data}
# end

# def yellow(_event_type, _event_content, data) do
#   {:keep_state, data}
# end

# def green({:call, from}, :change, data) do
#   :gen_statem.reply(from, :switched_to_yellow)
#   {:next_state, :yellow, data}
# end

# def green(_event_type, _event_content, data) do
#   {:keep_state, data}
# end
