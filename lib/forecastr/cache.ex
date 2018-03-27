defmodule Forecastr.Cache do
  @moduledoc """
  "Proxy" module for different caches
  """

  def get(:today, query) do
    Forecastr.Cache.Today.get(query)
  end

  def get(:in_five_days, query) do
    Forecastr.Cache.InFiveDays.get(query)
  end

  def set(:today, query, response) do
    Forecastr.Cache.Today.set(query, response)
  end

  def set(:in_five_days, query, response) do
    Forecastr.Cache.InFiveDays.set(query, response)
  end


end
