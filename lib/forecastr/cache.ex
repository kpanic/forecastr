defmodule Forecastr.Cache do
  @moduledoc """
  "Proxy" module for different caches
  """

  @spec get(:today, String.t()) :: map() | nil
  def get(:today, query) do
    Forecastr.Cache.Worker.get(Forecastr.Cache.Today, query)
  end

  @spec get(:in_five_days, String.t()) :: map() | nil
  def get(:in_five_days, query) do
    Forecastr.Cache.Worker.get(Forecastr.Cache.InFiveDays, query)
  end

  @spec set(:today, String.t(), map()) :: :ok
  def set(:today, query, response) do
    Forecastr.Cache.Worker.set(Forecastr.Cache.Today, query, response)
  end

  @spec set(:in_five_days, String.t(), map()) :: :ok
  def set(:in_five_days, query, response) do
    Forecastr.Cache.Worker.set(Forecastr.Cache.InFiveDays, query, response)
  end
end
