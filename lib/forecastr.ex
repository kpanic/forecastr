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

  @spec forecast(atom(), String.t(), list()) :: {:ok, map()} | {:error, atom()}
  def forecast(when_to_forecast, query, params \\ %{units: :metric}) do
    query = String.downcase(query)
    case Forecastr.Cache.get(query) do
      nil ->
        backend = Application.get_env(:forecastr, :backend)
        with {:ok, response = %HTTPoison.Response{status_code: 200}} <-  backend.weather(when_to_forecast, query,  params),
             expiration_minutes = Application.fetch_env!(:forecastr, :ttl)
        do
          :ok = Forecastr.Cache.set(query, response, ttl: expiration_minutes)

          response
        end
      response ->
        response
    end
  end
end
