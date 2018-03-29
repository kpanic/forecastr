defmodule Forecastr.Renderer.ASCII do
  @relevant_times %{
    "09:00:00" => "Morning",
    "12:00:00" => "Noon",
    "18:00:00" => "Afternoon",
    "21:00:00" => "Evening",
    "00:00:00" => "Night"
  }

  @weather_codes %{
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

  def show_all_boxes() do
    Enum.each(@weather_codes, fn {_, code} ->
      IO.puts(code)
      IO.write(box(code, 1, 2, 3, 4))
    end)
  end

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
    %{"description" => main_weather_condition, "id" => weather_id} = extract_main_weather(weather)
    weather_code = Map.get(@weather_codes, weather_id, :unknown)

    [
      ~s(Weather report: #{name}, #{country}\n),
      ~s(lat: #{lat}, lon: #{lon}\n),
      "\n",
      Table.table([box(weather_code, main_weather_condition, temp, temp_max, temp_min)], :unicode)
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


  # TODO: calculate dynamically the padding and create a function to append data
  # to the ASCII art
  def box(:codeunknown, description, temperature, temp_max, temp_min) do
    """
    .-.                     
    __)  #{description}     
    (    #{temperature} °C  
    `-᾿  max: #{temp_max} °C
      •  min: #{temp_min} °C
    """
  end

  def box(:codecloudy, description, temperature, temp_max, temp_min) do
    """
       .--.     #{description}     
    .-(    ).   #{temperature} °C  
    (___.__)__) max: #{temp_max} °C
                min: #{temp_min} °C
    """
  end

  def box(:codefog, description, temperature, temp_max, temp_min) do
    """
    _ - _ - _ - #{description}     
    _ - _ - _   #{temperature} °C  
    _ - _ - _ - max: #{temp_max} °C
                min: #{temp_min} °C
    """
  end

  def box(:codeheavyrain, description, temperature, temp_max, temp_min) do
    """
         .-.                      
        (   ). #{description}     
      (___(__) #{temperature} °C  
    ‚ʻ‚ʻ‚ʻ‚ʻ   max: #{temp_max} °C
    ‚ʻ‚ʻ‚ʻ‚ʻ   min: #{temp_min} °C
    """
  end

  def box(:codeheavyshowers, description, temperature, temp_max, temp_min) do
    """
    _`/\"\".-.                     
     ,\\_(   ).  #{description}     
     /\(___(__) #{temperature} °C  
       ‚ʻ‚ʻ‚ʻ‚ʻ max: #{temp_max} °C
       ‚ʻ‚ʻ‚ʻ‚ʻ min: #{temp_min} °C
    """
  end

  def box(:codeheavysnow, description, temperature, temp_max, temp_min) do
    """
       .-.                        
      (   ).   #{description}     
      (___(__) #{temperature} °C  
      * * * *  max: #{temp_max} °C
    * * * *    min: #{temp_min} °C
    """
  end

  def box(:codeheavysnowshowers, description, temperature, temp_max, temp_min) do
    """
    _`/\"\".-.                       
     ,\\_(   ).    #{description}     
      /(___(__)   #{temperature} °C  
          * * * * max: #{temp_max} °C
        * * * *   min: #{temp_min} °C
    """
  end

  def box(:codelightrain, description, temperature, temp_max, temp_min) do
    """
       .-.                       
      (   ).  #{description}     
    (___(__)  #{temperature} °C  
      ʻ ʻ ʻ ʻ max: #{temp_max} °C
    ʻ ʻ ʻ ʻ   min: #{temp_min} °C
    """
  end

  def box(:codelightshowers, description, temperature, temp_max, temp_min) do
    """
    _`/\"\".-.                     
     ,\\_(   ).  #{description}     
     /(___(__)  #{temperature} °C  
       ʻ ʻ ʻ ʻ  max: #{temp_max} °C
       ʻ ʻ ʻ ʻ  min: #{temp_min} °C
    """
  end

  def box(:codelightsleet, description, temperature, temp_max, temp_min) do
    """
      .-.                       
     (   ).  #{description}     
    (___(__) #{temperature} °C  
     ʻ * ʻ * max: #{temp_max} °C
    * ʻ * ʻ  min: #{temp_min} °C
    """
  end

  def box(:codelightsleetshowers, description, temperature, temp_max, temp_min) do
    """
    _`/\"\".-.                      
     ,\\_\(   ).  #{description}     
      /(___(__)  #{temperature} °C  
       ʻ * ʻ *   max: #{temp_max} °C
      * ʻ * ʻ    min: #{temp_min} °C
    """
  end

  def box(:codelightsnow, description, temperature, temp_max, temp_min) do
    """
       .-.                       
      (   ).  #{description}     
    (___(__)  #{temperature} °C  
      *  *  * max: #{temp_max} °C
    *  *  *   min: #{temp_min} °C
    """
  end

  def box(:codelightsnowshowers, description, temperature, temp_max, temp_min) do
    """
    _`/\"\".-.                      
     ,\\_\(   ).  #{description}     
     /(___(__)   #{temperature} °C  
       *  *  *   max: #{temp_max} °C
       *  *  *   min: #{temp_min} °C
    """
  end

  def box(:codepartlycloudy, description, temperature, temp_max, temp_min) do
    """
      \\  /      #{description}     
    _ /\"\".-.    #{temperature} °C  
      \\_(   ).  max: #{temp_max} °C
      /(___(__) min: #{temp_min} °C
    """
  end

  def box(:codesunny, description, temperature, temp_max, temp_min) do
    """
      \\   /                     
       .-.    #{description}     
    ‒ (   ) ‒ #{temperature} °C  
       `-᾿    max: #{temp_max} °C
      /   \\   min: #{temp_min} °C
    """
  end

  def box(:codethunderyheavyrain, description, temperature, temp_max, temp_min) do
    """
         .-.                        
        (   ).   #{description}     
      (___(__)   #{temperature} °C  
    ‚ʻ⚡ʻ‚⚡‚ʻ     max: #{temp_max} °C
    ‚ʻ‚ʻ⚡ʻ‚ʻ     min: #{temp_min} °C
    """
  end

  def box(:codethunderyshowers, description, temperature, temp_max, temp_min) do
    """
    _`/\"\".-.                     
     ,\\_(   ).  #{description}     
     /(___(__)  #{temperature} °C  
       ⚡ʻ ʻ⚡ʻ   max: #{temp_max} °C
     ʻ ʻ ʻ ʻ    min: #{temp_min} °C
    """
  end

  def box(:codethunderysnowshowers, description, temperature, temp_max, temp_min) do
    """
    _`/\"\".-.                     
     ,\\_(   ).  #{description}     
     /(___(__)  #{temperature} °C  
       *⚡ *⚡ *  max: #{temp_max} °C
       *  *  *  min: #{temp_min} °C
    """
  end

  def box(:codeverycloudy, description, temperature, temp_max, temp_min) do
    """
       .--.     #{description}     
    .-(    ).   #{temperature} °C  
    (___.__)__) max: #{temp_max} °C
                min: #{temp_min} °C
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
                                        }
                                      },
                                      acc ->
          %{"description" => main_weather_condition, "id" => weather_id} =
            extract_main_weather(weather)

          weather_code = Map.get(@weather_codes, weather_id, :unknown)
          time = extract_time(date_time)
          period_of_the_day = Map.get(@relevant_times, time)

          [
            "#{period_of_the_day}\n" <>
              box(weather_code, main_weather_condition, temp, temp_max, temp_min)
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
    List.first(weather)
  end

  defp extract_time(date) do
    <<_year::bytes-size(4)>> <>
      "-" <> <<_month::bytes-size(2)>> <> "-" <> <<_day::bytes-size(2)>> <> " " <> time = date

    time
  end
end
