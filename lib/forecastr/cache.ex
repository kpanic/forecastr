defmodule Forecastr.Cache do
  @moduledoc """
  "Proxy" module for different caches
  """

  @spec get(:today, String.t()) :: map() | nil
  def get(:today, query) do
    Forecastr.Cache.Worker.get(Forecastr.Cache.Today, query)
  end

  @spec get(:next_days, String.t()) :: map() | nil
  def get(:next_days, query) do
    Forecastr.Cache.Worker.get(Forecastr.Cache.NextDays, query)
  end

  @spec set(:today, String.t(), map()) :: :ok
  def set(:today, query, response) do
    Forecastr.Cache.Worker.set(Forecastr.Cache.Today, query, response)
  end

  @spec set(:next_days, String.t(), map()) :: :ok
  def set(:next_days, query, response) do
    Forecastr.Cache.Worker.set(Forecastr.Cache.NextDays, query, response)
  end
end
