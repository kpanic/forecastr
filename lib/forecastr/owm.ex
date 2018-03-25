defmodule Forecastr.OWM do

  def weather(time = :today, query, opts) do
    Forecastr.HTTP.get(owm_api_endpoint(time) <> "/?q=#{query}", [], params: opts)
  end
  def weather(time = :in_five_days, query, opts) do
    Forecastr.HTTP.get(owm_api_endpoint(time) <> "/?q=#{query}", [], params: opts)
  end

  def owm_api_endpoint(:today), do: "api.openweathermap.org/data/2.5/weather"
  def owm_api_endpoint(:in_five_days), do: "api.openweathermap.org/data/2.5/forecast"
end
