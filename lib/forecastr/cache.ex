defmodule Forecastr.Cache do
  @moduledoc """
  "Proxy" module for different caches
  """

  def get(:today, query) do
    Forecastr.Cache.Worker.get(Forecastr.Cache.Today, query)
  end

  def get(:in_five_days, query) do
    Forecastr.Cache.Worker.get(Forecastr.Cache.InFiveDays, query)
  end

  def set(:today, query, response) do
    Forecastr.Cache.Worker.set(Forecastr.Cache.Today, query, response)
  end

  def set(:in_five_days, query, response) do
    Forecastr.Cache.Worker.set(Forecastr.Cache.InFiveDays, query, response)
  end
end
