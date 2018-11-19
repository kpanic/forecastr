defmodule Forecastr.OWM do
  @moduledoc false

  @type when_to_forecast :: :today | :in_five_days
  @spec weather(when_to_forecast, String.t(), map()) :: {:ok, map()} | {:error, atom()}
  def weather(when_to_forecast, query, opts) do
    endpoint = owm_api_endpoint(when_to_forecast)
    fetch_weather_information(endpoint <> "?q=#{query}", opts)
  end

  @doc """
  Normalize for today's weather
  """
  @spec normalize(map()) :: {:ok, map()}
  def normalize(%{
        "name" => name,
        "sys" => %{"country" => country},
        "coord" => %{"lat" => lat, "lon" => lon},
        "weather" => weather,
        "main" => %{"temp" => temp, "temp_max" => temp_max, "temp_min" => temp_min}
      }) do
    normalized =
      weather
      |> extract_main_weather()
      |> add("name", name)
      |> add("country", country)
      |> add("coordinates", %{"lat" => lat, "lon" => lon})
      |> add("temp", temp)
      |> add("temp_max", temp_max)
      |> add("temp_min", temp_min)

    {:ok, normalized}
  end

  @doc """
  Normalize for 5 days weather
  """
  def normalize(%{
        "city" => %{
          "name" => name,
          "country" => country,
          "coord" => %{"lat" => lat, "lon" => lon}
        },
        "list" => forecast_list
      })
      when is_list(forecast_list) do
    normalized =
      Map.new()
      |> add("name", name)
      |> add("country", country)
      |> add("coordinates", %{"lat" => lat, "lon" => lon})
      |> add("list", forecast_list |> Enum.map(&normalize_forecast_list/1))

    {:ok, normalized}
  end

  defp fetch_weather_information(endpoint, opts) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           Forecastr.OWM.HTTP.get(endpoint, [], params: opts) do
      {:ok, Poison.decode!(body)}
    else
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      {:ok, %HTTPoison.Response{status_code: 400}} ->
        {:error, :not_found}

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        {:error, :api_key_invalid}

      error = {:error, _reason} ->
        error
    end
  end

  defp extract_main_weather(weather) do
    %{"description" => main_weather_condition, "id" => weather_id} = List.first(weather)
    %{"description" => main_weather_condition, "id" => weather_id}
  end

  defp normalize_forecast_list(%{
         "weather" => weather,
         "main" => %{
           "temp" => temp,
           "temp_max" => temp_max,
           "temp_min" => temp_min
         },
         "dt_txt" => dt_txt,
         "dt" => dt
       }) do
    weather
    |> extract_main_weather()
    |> add("temp", temp)
    |> add("temp_max", temp_max)
    |> add("temp_min", temp_min)
    |> add("dt_txt", dt_txt)
    |> add("dt", dt)
  end

  defp add(map, key, value) do
    map
    |> Map.put(key, value)
  end

  @spec owm_api_endpoint(when_to_forecast) :: String.t()
  def owm_api_endpoint(:today), do: "api.openweathermap.org/data/2.5/weather"
  def owm_api_endpoint(:in_five_days), do: "api.openweathermap.org/data/2.5/forecast"
end
