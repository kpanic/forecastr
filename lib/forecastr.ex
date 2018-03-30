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
  @spec forecast(when_to_forecast, String.t(), map()) :: binary() | {:error, atom()}
  def forecast(when_to_forecast, query, params \\ %{units: :metric}) do
    location = String.downcase(query)

    with {:ok, response} <- perform_query(location, when_to_forecast, params) do
      response
      |> render()
    end
  end

  @spec render(map()) :: String.t()
  def render(response) do
    renderer = Application.get_env(:forecastr, :renderer)

    response
    |> renderer.render()
  end

  @type response :: map()
  @type query :: String.t()
  @spec perform_query(query, when_to_forecast, map()) :: {:ok, response} | {:error, atom()}
  def perform_query(query, when_to_forecast, params) do
    with {:ok, :miss} <- fetch_from_cache(when_to_forecast, query),
         {:ok, response} <- fetch_from_backend(when_to_forecast, query, params),
         :ok = Forecastr.Cache.set(when_to_forecast, query, response) do
      {:ok, response}
    else
      {:ok, _response} = response -> response
      {:error, _} = error -> error
    end
  end

  @spec fetch_from_cache(when_to_forecast, query) :: {:ok, :miss} | {:ok, map()}
  def fetch_from_cache(when_to_forecast, query) do
    case Forecastr.Cache.get(when_to_forecast, query) do
      nil -> {:ok, :miss}
      response -> {:ok, response}
    end
  end

  @spec fetch_from_backend(when_to_forecast, query, map()) :: {:ok, response}
  def fetch_from_backend(when_to_forecast, query, params) do
    backend = Application.get_env(:forecastr, :backend)
    backend.weather(when_to_forecast, query, params)
  end
end
