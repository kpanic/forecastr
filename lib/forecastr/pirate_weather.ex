defmodule Forecastr.PirateWeather do
  @moduledoc false

  alias Forecastr.Geocoder

  @type when_to_forecast :: :today | :next_days
  @spec weather(when_to_forecast, String.t(), map()) :: {:ok, map()} | {:error, atom()}
  def weather(when_to_forecast, query, opts) do
    case api_endpoint(when_to_forecast) do
      nil -> {:error, :no_api_key}
      endpoint ->
    params = convert_params(opts)

    %{
      "lat" => lat,
      "lon" => lon,
      "address" => %{
        "city" => city,
        "country" => country
      }
    } =
      query
      |> Geocoder.geocode()
      |> pick_location()

    with {:ok, forecast} <- fetch_weather_information(endpoint <> "/#{lat},#{lon}", params) do
      {:ok,
       forecast
       |> add("name", city)
       |> add("country", country)
       |> add("when_to_forecast", Atom.to_string(when_to_forecast))}
    end
  end
  end

  @spec normalize(map()) :: {:ok, map()}
  @doc """
  Normalize for today's weather or for the next 3 days weather
  """
  def normalize(%{
        "when_to_forecast" => "today",
        "name" => name,
        "country" => country,
        "latitude" => lat,
        "longitude" => lon,
        "currently" => %{"temperature" => temp = temp_max = temp_min} = weather
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

  def normalize(%{
        "when_to_forecast" => "next_days",
        "name" => name,
        "country" => country,
        "latitude" => lat,
        "longitude" => lon,
        "hourly" => %{"data" => forecast_list}
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
    case HTTPoison.get(endpoint, [], params: opts) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body)}

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
    %{"summary" => main_weather_condition, "icon" => icon_name} = weather
    %{"description" => main_weather_condition, "id" => icon_name}
  end

  defp normalize_forecast_list(%{
         "summary" => main_weather_condition,
         "icon" => icon,
         "temperature" => temp = temp_max = temp_min,
         "time" => time
       }) do
    date = time |> DateTime.from_unix!() |> DateTime.to_date() |> to_string()
    time = time |> DateTime.from_unix!() |> DateTime.to_time() |> to_string()

    Map.new()
    |> add("temp", temp)
    |> add("temp_max", temp_max)
    |> add("temp_min", temp_min)
    |> add("dt_txt", "#{date} #{time}")
    |> add("dt", time)
    |> add("description", main_weather_condition)
    |> add("id", icon)
  end

  defp add(map, key, value) do
    map
    |> Map.put(key, value)
  end

  @spec api_endpoint(when_to_forecast) :: String.t()
  def api_endpoint(_) do
    case Application.get_env(:forecastr, :appid) do
      appid when is_binary(appid) and appid !="" ->
    "https://api.pirateweather.net/forecast/#{appid}"
    _ -> nil
      end
  end

  defp convert_params(%{units: :imperial} = params), do: Map.put(params, :units, "us")
  defp convert_params(%{units: _} = params), do: Map.put(params, :units, "si")
  defp convert_params(%{} = params), do: params
  defp convert_params(params) when is_list(params), do: Map.new(params) |> convert_params()

  defp pick_location(%{"address" => %{"city" => _city}} = body), do: body

  defp pick_location(%{"address" => %{"town" => town}} = body),
    do: put_in(body, ["address", "city"], town)

  defp pick_location(%{"address" => %{"village" => village}} = body),
    do: put_in(body, ["address", "city"], village)

  defp pick_location(%{"address" => %{"province" => province}} = body),
    do: put_in(body, ["address", "city"], province)

  defp pick_location(%{"address" => %{"suburb" => suburb}} = body),
    do: put_in(body, ["address", "city"], suburb)

  defp pick_location({"address", address} = body), do: %{"address" => address} |> pick_location()

end
