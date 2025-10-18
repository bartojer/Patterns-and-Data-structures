

defmodule Soupervisor do
  use Supervisor

  def start_link do
    IO.puts("starting soupy...")
    Supervisor.start_link(__MODULE__, :ok, name: :soupervisor)
  end

  def init(_) do
    children = [
      Supervisor.child_spec({ConveyorSupervisor, :ok}, id: :sub_super_1),
      Supervisor.child_spec({ConveyorSupervisor, :ok}, id: :sub_super_2)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end









defmodule SoupPool do
  use Supervisor

  def start_link do
    IO.puts("Starting poolervisor...")
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  def init(_) do
    children = [
      Supervisor.child_spec({Stock, [%{}]}, restart: :temporary)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule DynamicSoup do
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule MyPool do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    Supervisor.init([], strategy: :one_for_one)
  end
end

defmodule DelayedSupervisor do
  def start_link(immediate, delayed, delay_ms) do
    {:ok, sup} = Supervisor.start_link(__MODULE__, immediate, [])

    :timer.apply_after(delay_ms, Supervisor, :start_child, [sup, delayed])

    {:ok, sup}
  end

  def init({module, args}) do
    Supervisor.init([{module, args}], strategy: :one_for_one)
  end
end

defmodule DelayedSupervisor2 do
  use Supervisor

  @doc """
  Starts a supervisor that:

    1. Immediately starts `{mod1, args1}`
    2. After `delay_ms` milliseconds, starts `{mod2, args2}`

  ## Example

      DelayedSupervisor.start_link(
        {MyApp.WorkerA, [foo: 1]},
        {MyApp.WorkerB, [bar: 2]},
        5_000
      )
  """
  @spec start_link({module(), keyword()}, {module(), keyword()}, non_neg_integer()) ::
          {:ok, pid()} | {:error, any()}
  def start_link(immediate, delayed, delay_ms) do
    # 1) start the supervisor with only the immediate child
    {:ok, sup} = Supervisor.start_link(__MODULE__, immediate, name: __MODULE__)

    # 2) schedule the delayed child injection
    :timer.apply_after(delay_ms, Supervisor, :start_child, [sup, delayed])

    {:ok, sup}
  end

  @impl true
  def init({mod, args}) do
    # Use the {Module, args} shorthand to start mod.start_link(args)
    Supervisor.init([{mod, args}], strategy: :one_for_one)
  end
end
