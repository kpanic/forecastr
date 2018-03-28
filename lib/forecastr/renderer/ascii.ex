defmodule Forecastr.Renderer.ASCII do
  @relevant_times %{
    "09:00:00" => "Morning",
    "12:00:00" => "Noon",
    "18:00:00" => "Afternoon",
    "21:00:00" => "Evening",
    "00:00:00" => "Night"
  }

  @doc "render can be called with [:return :buffer] to avoid printing to stdout"
  def render(weather, opts \\ [])
  @doc "Render today weather condition"
  def render(
        %{
          "name" => name,
          "sys" => %{"country" => country},
          "coord" => %{"lat" => lat, "lon" => lon},
          "weather" => weather,
          "main" => %{"temp" => temp, "temp_max" => temp_max, "temp_min" => temp_min}
        },
        opts
      ) do
    main_weather_condition = extract_main_weather(weather)

    [
      ~s(Weather report: #{name}, #{country}\n),
      ~s(lat: #{lat}, lon: #{lon}\n),
      "\n",
      Table.table([box(main_weather_condition, temp, temp_max, temp_min)], :unicode)
    ]
    |> render(opts)
  end
  @doc "Render five days weather condition"
  def render(
        %{
          "city" => %{
            "name" => name,
            "country" => country,
            "coord" => %{"lat" => lat, "lon" => lon}
          },
          "list" => forecast_list
        },
        opts
      )
      when is_list(forecast_list) do

    forecasts =
      forecast_list
      |> extract_relevant_times()
      |> group_by_date()
      |> prepare_forecasts_for_rendering()

    ([
       ~s(Weather report: #{name}, #{country}\n),
       ~s(lat: #{lat}, lon: #{lon}\n),
       "\n"
     ] ++ [forecasts])
    |> render(opts)
  end
  def render(output, return: :buffer) when is_list(output) do
    output
  end
  def render(output, _opts) when is_list(output) do
    IO.write(output)
  end


  def box(description, temperature, temp_max, temp_min) do
    # TODO: create different ASCII art for different weather conditions :)
    """
      \\  /       #{description}
    _ /''.-.     #{temperature} °C
      \\_(   ).   max: #{temp_max} °C
      /(___(__)  min: #{temp_min} °C
    """
  end

  defp prepare_forecasts_for_rendering(forecasts) do
    forecasts
    |> Enum.map(fn {date, forecasts} ->
      forecasts =
        Enum.reduce(forecasts, [], fn %{
          "weather" => weather,
          "dt_txt" => date_time,
          "main" => %{
            "temp" => temp,
            "temp_max" => temp_max,
            "temp_min" => temp_min
          }}, acc ->
            main_weather_condition = extract_main_weather(weather)
            time = extract_time(date_time)
            period_of_the_day = Map.get(@relevant_times, time)

            [
              "#{period_of_the_day}\n" <> box(main_weather_condition, temp, temp_max, temp_min)
              | acc
            ]
        end)
        |> Enum.reverse()
      [Table.table([date], :unicode), Table.table([forecasts], :unicode)]
    end)
  end

  defp group_by_date(list) do
    Enum.group_by(list, fn element ->
      <<year::bytes-size(4)>> <>
        "-" <> <<month::bytes-size(2)>> <> "-" <> <<day::bytes-size(2)>> <> _rest =
        element["dt_txt"]

      year <> "-" <> month <> "-" <> day
    end)
  end

  defp extract_relevant_times(forecast_list) do
    forecast_list
    |> Enum.filter(fn element ->
      time = extract_time(element["dt_txt"])
      time in Map.keys(@relevant_times) == true
    end)
  end

  defp extract_main_weather(weather) do
    %{"description" => main_weather_condition} = List.first(weather)
    main_weather_condition
  end

  defp extract_time(date) do
    <<_year::bytes-size(4)>> <>
      "-" <> <<_month::bytes-size(2)>> <> "-" <> <<_day::bytes-size(2)>> <> " " <> time = date

    time
  end
end
