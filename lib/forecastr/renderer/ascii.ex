defmodule Forecastr.Renderer.ASCII do
  @moduledoc """
  ASCII renderer
  Render weather ASCII art from the response of Forecastr.OWM
  """

  import Forecastr.Renderer.Colours

  @relevant_times %{
    "09:00:00" => "Morning",
    "12:00:00" => "Noon",
    "18:00:00" => "Afternoon",
    "21:00:00" => "Evening",
    "00:00:00" => "Night"
  }

  @weekdays %{
    1 => "Mon",
    2 => "Tue",
    3 => "Wed",
    4 => "Thu",
    5 => "Fri",
    6 => "Sat",
    7 => "Sun"
  }

  @doc "Render today weather condition"
  @type weather :: map()
  @type output_type :: :ansi | :png
  @spec render(weather, output_type) :: :ok | list()
  def render(weather, output_type \\ :ascii)

  def render(
        %{
          "name" => name,
          "country" => country,
          "coordinates" => %{"lat" => lat, "lon" => lon},
          "temp" => temp,
          "temp_max" => temp_max,
          "temp_min" => temp_min,
          "id" => weather_id,
          "description" => main_weather_condition
        },
        output_type
      ) do
    weather_codes = get_weather_codes_for_backend(Application.get_env(:forecastr, :backend))
    weather_code = Map.get(weather_codes, weather_id, :codeunknown)

    bare_ascii =
      weather_code
      |> ascii_for(:ascii)
      |> String.split("\n")

    forecast =
      weather_code
      |> ascii_for(output_type)
      |> String.split("\n")
      |> append_reset_colours(output_type)
      |> append_weather_info(bare_ascii, main_weather_condition, temp, temp_max, temp_min)

    [
      ~s(Weather report: #{name}, #{country}\n),
      ~s(lat: #{lat}, lon: #{lon}\n),
      "\n",
      table([forecast], output_type)
    ]
  end

  @doc "Render five days weather condition"
  def render(
        %{
          "name" => name,
          "country" => country,
          "coordinates" => %{"lat" => lat, "lon" => lon},
          "list" => forecast_list
        },
        output_type
      )
      when is_list(forecast_list) do
    forecasts =
      forecast_list
      |> extract_relevant_times()
      |> group_by_date()
      |> prepare_forecasts_for_rendering(output_type)

    # TODO: align correctly tabular output when we have different ASCII art
    # shapes
    [
      [
        ~s(Weather report: #{name}, #{country}\n),
        ~s(lat: #{lat}, lon: #{lon}\n),
        "\n"
      ]
      | [forecasts]
    ]
  end

  defp determine_max_length(ascii_list),
    do: ascii_list |> Stream.map(&String.length/1) |> Enum.max()

  def append_reset_colours(ascii_list, output_type),
    do:
      Enum.map(
        ascii_list,
        fn line ->
          case String.trim(line) do
            # Do not reset blank lines, we have no opening
            "" -> line
            _ -> line <> reset(output_type)
          end
        end
      )

  # TODO: re-organize weather info with humidity etc
  # We should pass a map as a parameter
  def append_weather_info(
        ascii_art_list,
        ascii_list,
        description,
        temperature,
        temp_max,
        temp_min
      ) do
    # The weather information to append to the ASCII art
    weather_info = [
      "#{description}     ",
      "#{temperature} °C  ",
      "max: #{temp_max} °C",
      "min: #{temp_min} °C"
    ]

    weather_length = Enum.count(weather_info)
    ascii_art_length = Enum.count(ascii_art_list)

    # Concatenate the ascii subset with the weather info
    ascii_with_weather_info =
      ascii_art_list
      |> concat_ascii_with_weather_info(ascii_list, weather_info)

    # Add the rest of the ascii art
    [ascii_with_weather_info | Enum.slice(ascii_art_list, weather_length..ascii_art_length)]
    |> List.flatten()
    |> Enum.join("\n")
  end

  @spec ascii_for(atom(), atom()) :: String.t()
  def ascii_for(:codeunknown, output_type) do
    """
    #{light_white(output_type)}.-.
    #{light_white(output_type)}__)
    #{light_white(output_type)}(
    #{light_white(output_type)}`-᾿
    #{light_white(output_type)}  •
    """
  end

  def ascii_for(:codecloudy, output_type) do
    """
    #{light_white(output_type)}    .--.
    #{light_white(output_type)} .-(    ).
    #{light_white(output_type)}(___.__)__)
    #{normal(output_type)}
    """
  end

  def ascii_for(:codefog, output_type) do
    """
    #{light_white(output_type)}_ - _ - _ -
    #{light_white(output_type)}_ - _ - _
    #{light_white(output_type)}_ - _ - _ -
    #{light_white(output_type)}
    """
  end

  def ascii_for(:codeheavyrain, output_type) do
    """
    #{light_white(output_type)}     .-.
    #{light_white(output_type)}    (   ).
    #{light_white(output_type)}  (___(__)
    #{blue(output_type)}‚ʻ‚ʻ‚ʻ‚ʻ
    #{blue(output_type)}‚ʻ‚ʻ‚ʻ‚ʻ
    """
  end

  def ascii_for(:codeheavyshowers, output_type) do
    """
    #{yellow(output_type)}_`/\"\"#{reset(output_type)}#{light_white(output_type)}.-.
    #{yellow(output_type)} ,\\#{reset(output_type)}#{light_white(output_type)}_(   ).
    #{yellow(output_type)} /#{reset(output_type)}#{light_white(output_type)}\(___(__)
    #{blue(output_type)}   ‚ʻ‚ʻ‚ʻ‚ʻ
    #{blue(output_type)}   ‚ʻ‚ʻ‚ʻ‚ʻ
    """
  end

  def ascii_for(:codeheavysnow, output_type) do
    """
    #{white(output_type)}   .-.
    #{white(output_type)}  (   ).
    #{white(output_type)}  (___(__)
    #{light_white(output_type)}  * * * *
    #{light_white(output_type)}* * * *
    """
  end

  def ascii_for(:codeheavysnowshowers, output_type) do
    """
    #{yellow(output_type)}_`/\"\"#{reset(output_type)}#{white(output_type)}.-.
    #{yellow(output_type)} ,\\_#{reset(output_type)}#{white(output_type)}(   ).
    #{yellow(output_type)}  /#{reset(output_type)}#{white(output_type)}(___(__)
    #{light_white(output_type)}      * * * *
    #{light_white(output_type)}    * * * *
    """
  end

  def ascii_for(:codelightrain, output_type) do
    """
    #{white(output_type)}   .-.
    #{white(output_type)}  (   ).
    #{white(output_type)}(___(__)
    #{blue(output_type)}  ʻ ʻ ʻ ʻ
    #{blue(output_type)}ʻ ʻ ʻ ʻ
    """
  end

  def ascii_for(:codelightshowers, output_type) do
    """
    #{yellow(output_type)}_`/\"\"#{reset(output_type)}#{white(output_type)}.-.
    #{yellow(output_type)} ,\\_#{reset(output_type)}(#{white(output_type)}   ).
    #{yellow(output_type)}  /#{reset(output_type)}#{white(output_type)}(___(__)
    #{blue(output_type)}   ʻ ʻ ʻ ʻ
    #{blue(output_type)}   ʻ ʻ ʻ ʻ
    """
  end

  def ascii_for(:codelightsleet, output_type) do
    """
    #{white(output_type)}  .-.
    #{white(output_type)} (   ).
    #{white(output_type)}(___(__)
    #{blue(output_type)} ʻ#{reset(output_type)}#{light_white(output_type)} *#{reset(output_type)} ʻ #{
      light_white(output_type)
    }*
    #{light_white(output_type)}*#{reset(output_type)}#{blue(output_type)} ʻ#{reset(output_type)} *#{
      blue(output_type)
    } ʻ
    """
  end

  def ascii_for(:codelightsleetshowers, output_type) do
    """
    #{yellow(output_type)}_`/\"\"#{white(output_type)}.-.
    #{yellow(output_type)} ,\\_#{white(output_type)}\(   ).
    #{yellow(output_type)}  /#{reset(output_type)}#{white(output_type)}(___(__)
    #{blue(output_type)}   ʻ#{reset(output_type)}#{white(output_type)} *#{blue(output_type)} ʻ#{
      reset(output_type)
    }#{white(output_type)} *
    #{white(output_type)}  *#{reset(output_type)}#{blue(output_type)} ʻ#{reset(output_type)}#{
      white(output_type)
    } *#{reset(output_type)}#{blue(output_type)} ʻ
    """
  end

  def ascii_for(:codelightsnow, output_type) do
    """
    #{white(output_type)}   .-.
    #{white(output_type)}  (   ).
    #{white(output_type)}(___(__)
    #{light_white(output_type)}  *  *  *
    #{light_white(output_type)}*  *  *
    """
  end

  def ascii_for(:codelightsnowshowers, output_type) do
    """
    #{yellow(output_type)}_`/\"\"#{reset(output_type)}#{white(output_type)}.-.
    #{yellow(output_type)} ,\\_#{reset(output_type)}#{white(output_type)}\(   ).
    #{yellow(output_type)} /#{reset(output_type)}#{white(output_type)}(___(__)
    #{light_white(output_type)}   *  *  *
    #{light_white(output_type)}   *  *  *
    """
  end

  def ascii_for(:codepartlycloudy, output_type) do
    """
    #{yellow(output_type)}  \\  /
    #{yellow(output_type)}_ /\"\"#{reset(output_type)}#{white(output_type)}.-.
    #{yellow(output_type)}  \\#{reset(output_type)}#{white(output_type)}_(   ).
    #{yellow(output_type)}  /#{reset(output_type)}#{white(output_type)}(___(__)
    """
  end

  def ascii_for(:codesunny, output_type) do
    """
    #{bright_yellow(output_type)}  \\   /
    #{bright_yellow(output_type)}   .-.
    #{bright_yellow(output_type)}‒ (   ) ‒
    #{bright_yellow(output_type)}   `-᾿
    #{bright_yellow(output_type)}  /   \\
    """
  end

  def ascii_for(:codethunderyheavyrain, output_type) do
    """
    #{white(output_type)}    .-.
    #{white(output_type)}   (   ).
    #{white(output_type)}  (___(__)
    #{blue(output_type)}‚ʻ#{reset(output_type)}#{bright_yellow(output_type)}⚡#{reset(output_type)}#{
      blue(output_type)
    }ʻ‚#{reset(output_type)}#{bright_yellow(output_type)}⚡#{reset(output_type)}#{
      blue(output_type)
    }‚ʻ
    #{blue(output_type)}‚ʻ‚ʻ#{reset(output_type)}#{bright_yellow(output_type)}⚡#{
      reset(output_type)
    }#{blue(output_type)}ʻ‚ʻ
    """
  end

  def ascii_for(:codethunderyshowers, output_type) do
    """
    #{yellow(output_type)}_`/\"\"#{reset(output_type)}#{white(output_type)}.-.
    #{yellow(output_type)} ,\\#{reset(output_type)}#{white(output_type)}_(   ).
    #{yellow(output_type)} /#{reset(output_type)}#{white(output_type)}(___(__)
    #{bright_yellow(output_type)}  ⚡#{reset(output_type)}#{blue(output_type)}ʻ ʻ#{
      reset(output_type)
    }#{bright_yellow(output_type)}⚡ʻ
    #{blue(output_type)} ʻ ʻ ʻ ʻ
    """
  end

  def ascii_for(:codethunderysnowshowers, output_type) do
    """
    #{yellow(output_type)}_`/\"\"#{reset(output_type)}.-.
    #{yellow(output_type)} ,\\#{reset(output_type)}_(   ).
    #{yellow(output_type)} /#{reset(output_type)}(___(__)
    #{light_white(output_type)}   *#{reset(output_type)}#{bright_yellow(output_type)}⚡#{
      reset(output_type)
    }#{light_white(output_type)} *#{reset(output_type)}#{bright_yellow(output_type)}⚡
    #{light_white(output_type)}   *  *  *
    """
  end

  def ascii_for(:codeverycloudy, output_type) do
    """
    #{white(output_type)}   .--.
    #{white(output_type)}.-(    ).
    #{white(output_type)}(___.__)__)
    #{normal(output_type)}
    """
  end

  @unicode_range ~r/[\x{2600}-\x{9FFF}]/u
  defp concat_ascii_with_weather_info(ascii_art_list, ascii_list, weather_info) do
    blank_space = 1

    weather_length = Enum.count(weather_info)

    ascii_max_line_length = determine_max_length(ascii_list)
    ascii_art_subset = Enum.slice(ascii_art_list, 0..weather_length)
    ascii_subset = Enum.slice(ascii_list, 0..weather_length)

    Enum.map(Stream.zip([ascii_art_subset, weather_info, ascii_subset]), fn {ascii_art, weather,
                                                                             ascii} ->
      unicode_count =
        @unicode_range
        |> Regex.scan(ascii)
        |> List.flatten()
        |> Enum.count()

      ascii_length = String.length(ascii)
      to_pad = ascii_max_line_length - ascii_length - unicode_count + blank_space
      padding = String.duplicate(" ", to_pad)

      "#{ascii_art}#{padding}#{weather}"
    end)
  end

  defp prepare_forecasts_for_rendering(forecasts, output_type) do
    forecasts
    |> Enum.map(fn {date, forecasts} ->
      day =
        Map.get(
          @weekdays,
          date
          |> Date.from_iso8601!()
          |> Date.day_of_week()
        )

      forecasts =
        forecasts
        |> Enum.reduce([], fn %{
                                "dt_txt" => date_time,
                                "temp" => temp,
                                "temp_max" => temp_max,
                                "temp_min" => temp_min,
                                "description" => main_weather_condition,
                                "id" => weather_id
                              },
                              acc ->
          weather_codes = get_weather_codes_for_backend(Application.get_env(:forecastr, :backend))
          weather_code = Map.get(weather_codes, weather_id, :codeunknown)
          time = extract_time(date_time)
          period_of_the_day = Map.get(@relevant_times, time)

          bare_ascii =
            weather_code
            |> ascii_for(:ascii)
            |> String.split("\n")

          ascii =
            weather_code
            |> ascii_for(output_type)
            |> String.split("\n")
            |> append_reset_colours(output_type)
            |> append_weather_info(bare_ascii, main_weather_condition, temp, temp_max, temp_min)

          ["#{period_of_the_day} [#{time}]\n" <> ascii | acc]
        end)
        |> Enum.reverse()

      [table([[day, date]], output_type), table([forecasts], output_type)]
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
    |> Stream.filter(fn element ->
      time = extract_time(element["dt_txt"])
      time in Map.keys(@relevant_times) == true
    end)
  end

  defp extract_time(date) do
    <<_year::bytes-size(4)>> <>
      "-" <> <<_month::bytes-size(2)>> <> "-" <> <<_day::bytes-size(2)>> <> " " <> time = date

    time
  end

  def table(data, :ascii), do: Elbat.table(data, :unicode)
  def table(data, :ansi), do: Elbat.table(data, :unicode)
  def table(data, :html), do: Elbat.table(data, :unicode)
  def table(data, _), do: data

  # NOTE: this is a reduced set compared to OWM
  def get_weather_codes_for_backend(Forecastr.Darksky) do
    %{
      "clear-day" => :codesunny,
      "clear-night" => :codesunny,
      "cloudy" => :codecloudy,
      "fog" => :codefog,
      "partly-cloudy-day" => :codepartlycloudy,
      "partly-cloudy-night" => :codepartlycloudy,
      "rain" => :codeheavyrain,
      "sleet" => :codelightsleet,
      "snow" => :codelightsnow
    }
  end

  def get_weather_codes_for_backend(_) do
    %{
      200 => :codethunderyshowers,
      201 => :codethunderyshowers,
      210 => :codethunderyshowers,
      230 => :codethunderyshowers,
      231 => :codethunderyshowers,
      202 => :codethunderyheavyrain,
      211 => :codethunderyheavyrain,
      212 => :codethunderyheavyrain,
      221 => :codethunderyheavyrain,
      232 => :codethunderyheavyrain,
      300 => :codelightrain,
      301 => :codelightrain,
      310 => :codelightrain,
      311 => :codelightrain,
      313 => :codelightrain,
      321 => :codelightrain,
      302 => :codeheavyrain,
      312 => :codeheavyrain,
      314 => :codeheavyrain,
      500 => :codelightshowers,
      501 => :codelightshowers,
      502 => :codeheavyshowers,
      503 => :codeheavyshowers,
      504 => :codeheavyshowers,
      511 => :codelightsleet,
      520 => :codelightshowers,
      521 => :codelightshowers,
      522 => :codeheavyshowers,
      531 => :codeheavyshowers,
      600 => :codelightsnow,
      601 => :codelightsnow,
      602 => :codeheavysnow,
      611 => :codelightsleet,
      612 => :codelightsleetshowers,
      615 => :codelightsleet,
      616 => :codelightsleet,
      620 => :codelightsnowshowers,
      621 => :codelightsnowshowers,
      622 => :codeheavysnowshowers,
      701 => :codefog,
      711 => :codefog,
      721 => :codefog,
      741 => :codefog,
      # sand, dust whirls
      731 => :codeunknown,
      # sand
      751 => :codeunknown,
      # dust
      761 => :codeunknown,
      # volcanic ash
      762 => :codeunknown,
      # squalls
      771 => :codeunknown,
      # tornado
      781 => :codeunknown,
      800 => :codesunny,
      801 => :codepartlycloudy,
      802 => :codecloudy,
      803 => :codeverycloudy,
      804 => :codeverycloudy,
      # tornado
      900 => :codeunknown,
      # tropical storm
      901 => :codeunknown,
      # hurricane
      902 => :codeunknown,
      # cold
      903 => :codeunknown,
      # hot
      904 => :codeunknown,
      # windy
      905 => :codeunknown,
      # hail
      906 => :codeunknown,
      # calm
      951 => :codeunknown,
      # light breeze
      952 => :codeunknown,
      # gentle breeze
      953 => :codeunknown,
      # moderate breeze
      954 => :codeunknown,
      # fresh breeze
      955 => :codeunknown,
      # strong breeze
      956 => :codeunknown,
      # high wind, near gale
      957 => :codeunknown,
      # gale
      958 => :codeunknown,
      # severe gale
      959 => :codeunknown,
      # storm
      960 => :codeunknown,
      # violent storm
      961 => :codeunknown,
      # hurricane
      962 => :codeunknown
    }
  end
end
