defmodule Forecastr do
  @moduledoc """
  Forecastr is an application that queries the Open Weather Map API

  The Forecastr user API is exposed in this way:

  # Query the OWM API for today's weather
  Forecastr.forecast(:today, query, params \\ %{})

  # Query the OWM API for the forecast in the next 5 days
  Forecastr.forecast(:in_five_days, query, params \\ %{})

  For example:

  Forecastr.forecast(:today, "Berlin")

  Forecastr.forecast(:in_five_days, "Berlin", %{units: :imperial})
  """

  @type when_to_forecast :: :today | :in_five_days
  @spec forecast(when_to_forecast, String.t(), map()) :: :ok | {:error, atom()}
  def forecast(when_to_forecast, query, params \\ %{units: :metric}) do
    location = query |> String.downcase()

    with {:ok, response} <- perform_query(location, when_to_forecast, params) do
      response |> render()
    end
  end

  @spec render(map()) :: String.t()
  def render(response) do
    renderer = Application.get_env(:forecastr, :renderer)
    response |> renderer.render()
  end

  @type response :: map()
  @type query :: String.t()
  @spec perform_query(query, when_to_forecast, map()) ::
          {:ok, response} | {:error, :fetch_from_backend_failed}
  def perform_query(query, when_to_forecast, params) do
    with {:get_cache, :miss} <- {:get_cache, fetch_from_cache(query)},
         {:fetch, {:ok, response}} <-
           {:fetch, fetch_from_backend(query, when_to_forecast, params)} do
      cache_response(query, response)
      {:ok, response}
    else
      {:get_cache, {:ok, response}} -> {:ok, response}
      {:fetch, _} -> {:error, :fetch_from_backend_failed}
    end
  end

  @spec fetch_from_cache(query) :: :ok
  def fetch_from_cache(query) do
    case query |> Forecastr.Cache.get() do
      nil -> :miss
      response -> {:ok, response}
    end
  end

  @spec fetch_from_backend(query, when_to_forecast, map()) :: {:ok, response}
  def fetch_from_backend(query, when_to_forecast, params) do
    backend = Application.get_env(:forecastr, :backend)
    backend.weather(when_to_forecast, query, params)
  end

  @spec cache_response(query, response) :: :ok | atom()
  def cache_response(query, response) do
    expiration_minutes = Application.get_env(:forecastr, :ttl, 10 * 60_000)
    Forecastr.Cache.set(query, response, ttl: expiration_minutes)
  end
end
