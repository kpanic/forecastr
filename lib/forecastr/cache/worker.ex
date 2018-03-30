defmodule Forecastr.Cache.Worker do
  use GenServer

  # Client API
  @spec start_link(Keyword.t()) :: {:ok, pid()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
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
  def init(state) do
    {:ok, state}
  end

  def handle_call({:get, query}, _from, state) do
    entry = Map.get(state, query)
    {:reply, entry, state}
  end

  def handle_call({:set, query, response, options}, _from, state) do
    state = Map.put(state, query, response)
    purge_cache(query, options)
    {:reply, :ok, state}
  end

  def purge_cache(query, ttl: minutes) do
    # Purge every N minutes
    Process.send_after(self(), {:purge_cache, query}, minutes)
  end

  def handle_info({:purge_cache, query}, state) do
    {:noreply, Map.delete(state, query)}
  end
end
