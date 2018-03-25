defmodule Forecastr.Cache do
  use GenServer

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(query) do
    GenServer.call(__MODULE__, {:get, query})
  end

  def set(query, response, options) do
    GenServer.call(__MODULE__, {:set, query, response, options})
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
