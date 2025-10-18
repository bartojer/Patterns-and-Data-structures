defmodule ConveyorSupervisor do
  use Supervisor

  def start_link(_) do
    IO.puts("Starting Conveyor Supervisor...")
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  # , name: :conv_soup

  def init(_) do
    children = [
      Supervisor.child_spec({Conveyor, 0}, id: :conveyor_1),
      Supervisor.child_spec({Conveyor, 0}, id: :conveyor_2)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule LightSwitch do
  def start_switch(state \\ :off) do
    spawn(fn -> switch_loop(state) end)
  end

  defp switch_loop(state) do
    receive do
      :off ->
        IO.puts("light is off")
        switch_loop(:off)

      :on ->
        IO.puts("light is on")
        switch_loop(:on)

      :state ->
        IO.puts("light is #{state}")
        switch_loop(state)
    end
  end
end

defmodule For do
  def loop(0, _, data), do: data

  def loop(count, lambda, data) do
    loop(count - 1, lambda, lambda.(data))
  end
end
