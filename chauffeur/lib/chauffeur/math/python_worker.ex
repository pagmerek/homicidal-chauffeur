defmodule Chauffeur.Math.PythonWorker do
  use GenServer

  require Logger

  @timeout 10_000
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_controls(t, z, w1, w2, r, v, u) do
    {v1, v2} = v
    {z1, z2} = z

    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          GenServer.call(pid, {:get_controls, t, z1, z2, w1, w2, r, v1, v2, u})
        end,
        @timeout
      )
    end)
    |> Task.await(@timeout)
  end

  @impl true
  def init(_) do
    path =
      [:code.priv_dir(:chauffeur), "python"]
      |> Path.join()

    pybinpath = '/Users/pgmerek/opt/anaconda3/bin/python'

    with {:ok, pid} <- :python.start([{:python_path, to_charlist(path)}, {:python, pybinpath}]) do
      Logger.info("[#{__MODULE__}] Started python worker")
      {:ok, pid}
    end
  end

  @impl true
  def handle_call({:get_controls, t, z1, z2, w1, w2, r, v1, v2, u}, _from, pid) do
    result = :python.call(pid, :control_math, :get_controls, [t, z1, z2, w1, w2, r, v1, v2, u])
    {:reply, {:ok, result}, pid}
  end
end
