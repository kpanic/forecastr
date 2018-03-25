defmodule Forecastr.Renderer.ASCII do
  @hours_to_take [
    {"09:00:00", "Morning"},
    {"12:00:00", "Noon"},
    {"18:00:00", "Afternoon"},
    {"21:00:00", "Evening"},
    {"00:00:00", "Night"}
  ]

  def render(%{
        "name" => name,
        "sys" => %{"country" => country},
        "coord" => %{"lat" => lat, "lon" => lon},
        "weather" => [%{"description" => description}],
        "main" => %{"temp" => temp, "temp_max" => temp_max, "temp_min" => temp_min}
      }) do
    IO.puts(~s(Weather report: #{name}, #{country}))
    IO.puts(~s(lat: #{lat}, lon: #{lon}))
    IO.puts("")
    IO.write(Table.table([box(description, temp, temp_max, temp_min)], :unicode))
  end

  def render(%{
        "city" => %{
          "name" => name,
          "country" => country,
          "coord" => %{"lat" => lat, "lon" => lon}
        },
        "list" => list
      })
      when is_list(list) do
    IO.puts(~s(Weather report: #{name}, #{country}))
    IO.puts(~s(lat: #{lat}, lon: #{lon}))
    IO.puts("")

    group_by_date(list)
    |> Enum.each(fn {date, forecasts} ->
      IO.write(Table.table([date], :unicode))

      forecasts =
        forecasts
        |> group_by_specific_time()
        |> Enum.reduce([], fn {hour,
                               [
                                 %{
                                   "weather" => [%{"description" => description}],
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

          ["#{period_of_the_day}\n" <> box(description, temp, temp_max, temp_min) | acc]
        end)
        |> Enum.reverse()

      IO.write(Table.table([forecasts], :unicode))
    end)
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
end
