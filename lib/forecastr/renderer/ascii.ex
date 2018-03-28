defmodule Forecastr.Renderer.ASCII do
  @hours_to_take [
    {"09:00:00", "Morning"},
    {"12:00:00", "Noon"},
    {"18:00:00", "Afternoon"},
    {"21:00:00", "Evening"},
    {"00:00:00", "Night"}
  ]

  @doc "Render today weather condition"
  def render(%{
        "name" => name,
        "sys" => %{"country" => country},
        "coord" => %{"lat" => lat, "lon" => lon},
        "weather" => weather,
        "main" => %{"temp" => temp, "temp_max" => temp_max, "temp_min" => temp_min}
      }) do
    main_weather_condition = extract_main_weather(weather)

    [
      ~s(Weather report: #{name}, #{country}\n),
      ~s(lat: #{lat}, lon: #{lon}\n),
      "\n",
      Table.table([box(main_weather_condition, temp, temp_max, temp_min)], :unicode)
    ]
    |> render()
  end

  @doc "Render five days weather condition"
  def render(%{
        "city" => %{
          "name" => name,
          "country" => country,
          "coord" => %{"lat" => lat, "lon" => lon}
        },
        "list" => list
      })
      when is_list(list) do
    weather =
      group_by_date(list)
      |> Enum.map(fn {date, forecasts} ->
        forecasts =
          forecasts
          |> group_by_specific_time()
          |> Enum.reduce([], fn {hour,
                                 [
                                   %{
                                     "weather" => weather,
                                     "main" => %{
                                       "temp" => temp,
                                       "temp_max" => temp_max,
                                       "temp_min" => temp_min
                                     }
                                   }
                                 ]},
                                acc ->
            {_hour, period_of_the_day} =
              Enum.filter(@hours_to_take, fn {default_hour, _} -> default_hour == hour end)
              |> List.first()

            main_weather_condition = extract_main_weather(weather)

            [
              "#{period_of_the_day}\n" <> box(main_weather_condition, temp, temp_max, temp_min)
              | acc
            ]
          end)
          |> Enum.reverse()

        [Table.table([date], :unicode), Table.table([forecasts], :unicode)]
      end)
      |> List.flatten()

    ([
       ~s(Weather report: #{name}, #{country}\n),
       ~s(lat: #{lat}, lon: #{lon}\n),
       "\n"
     ] ++ weather)
    |> render()
  end

  def render(output) when is_list(output) do
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

  defp group_by_date(list) do
    Enum.group_by(list, fn element ->
      <<year::bytes-size(4)>> <>
        "-" <> <<month::bytes-size(2)>> <> "-" <> <<day::bytes-size(2)>> <> _rest =
        element["dt_txt"]

      year <> "-" <> month <> "-" <> day
    end)
    |> Enum.sort()
  end

  defp group_by_specific_time(forecasts) do
    hours_to_lookup = Enum.map(@hours_to_take, fn {hour, _} -> hour end)

    Enum.group_by(forecasts, fn element ->
      <<_year::bytes-size(4)>> <>
        "-" <> <<_month::bytes-size(2)>> <> "-" <> <<_day::bytes-size(2)>> <> " " <> time =
        element["dt_txt"]

      time
    end)
    |> Map.take(hours_to_lookup)
    |> Enum.sort()
  end

  defp extract_main_weather(weather) do
    %{"description" => main_weather_condition} = List.first(weather)
    main_weather_condition
  end
end
