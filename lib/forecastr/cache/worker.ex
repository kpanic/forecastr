defmodule Forecastr.Cache.Worker do
  @moduledoc false

  use GenServer

  # Client API
  @spec start_link(Keyword.t()) :: {:ok, pid()}
  def start_link([name: worker_name] = opts) do
    GenServer.start_link(__MODULE__, %{name: worker_name, timer_ref: nil}, opts)
  end

  @spec get(atom(), String.t()) :: map() | nil
  def get(name, query) do
    GenServer.call(name, {:get, query})
  end

  @spec set(atom(), String.t(), map()) :: :ok
  def set(name, query, response) do
    expiration_minutes = Application.get_env(:forecastr, :ttl, 10 * 60_000)
    GenServer.call(name, {:set, query, response, ttl: expiration_minutes})
  end

  # Server callbacks
  def init(%{name: worker_name} = state) do
    ^worker_name = :ets.new(worker_name, [:named_table])
    {:ok, state}
  end

  def handle_call({:get, query}, _from, %{name: worker_name} = state) do
    entry =
      case :ets.lookup(worker_name, query) do
        [] -> nil
        [{_key, value}] -> value
      end

    {:reply, entry, state}
  end

  def handle_call(
        {:set, query, response, options},
        _from,
        %{name: worker_name, timer_ref: timer_ref} = state
      ) do
    true = :ets.insert(worker_name, {query, response})
    timer_ref = schedule_purge_cache(query, timer_ref, options)
    {:reply, :ok, %{state | timer_ref: timer_ref}}
  end

  def schedule_purge_cache(query, nil = _timer_ref, ttl: minutes),
    do: Process.send_after(self(), {:purge_cache, query}, minutes)

  def schedule_purge_cache(query, timer_ref, ttl: minutes) do
    Process.cancel_timer(timer_ref)
    Process.send_after(self(), {:purge_cache, query}, minutes)
  end

  def handle_info({:purge_cache, query}, %{name: worker_name} = state) do
    true = :ets.delete(worker_name, query)
    {:noreply, state}
  end
end
