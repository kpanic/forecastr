defmodule ForecastrTest do
  use Forecastr.CacheCase

  import ExUnit.CaptureIO
  @moduletag :capture_log

  defmodule OWMBackendToday do
    def weather(_when_to_forecast, _city, _params) do
      {:ok, ForecastrTest.today_weather()}
    end
  end

  defmodule OWMBackendFiveDays do
    def weather(_when_to_forecast, _city, _params) do
      {:ok, ForecastrTest.five_days_weather()}
    end
  end

  defmodule OWMBackendError do
    def weather(_when_to_forecast, _city, _params) do
      {:error, :not_found}
    end
  end

  test "Forecast with an empty string" do
    assert is_nil(Forecastr.forecast(:today, "")) == true
    assert is_nil(Forecastr.forecast(:in_five_days, "")) == true
  end

  test "Forecast for a city today" do
    Application.put_env(:forecastr, :backend, OWMBackendToday)
    output = capture_io(fn -> Forecastr.forecast(:today, "Wonderland") end)
    assert String.length(output) > 0
  end

  test "Forecast for a city returns an error" do
    Application.put_env(:forecastr, :backend, OWMBackendError)
    assert {:error, _} = Forecastr.forecast(:today, "Mars")
    assert {:error, _} = Forecastr.forecast(:in_five_days, "Hale-Bopp")
  end

  test "Forecast for a city in 5 days" do
    Application.put_env(:forecastr, :backend, OWMBackendFiveDays)
    output = capture_io(fn -> Forecastr.forecast(:in_five_days, "Wonderland") end)
    assert String.length(output) > 0
  end

  test "Forecastr.forecast/3 cache correctly :today" do
    Application.put_env(:forecastr, :backend, OWMBackendToday)
    capture_io(fn -> Forecastr.forecast(:today, "Wonderland") end)
    state = :sys.get_state(Forecastr.Cache.Today)

    assert %{"wonderland" => today_weather()} == state
  end

  test "Forecastr.forecast/3 cache correctly :in_five_days" do
    Application.put_env(:forecastr, :backend, OWMBackendFiveDays)
    capture_io(fn -> Forecastr.forecast(:in_five_days, "Wonderland") end)
    state = :sys.get_state(Forecastr.Cache.InFiveDays)

    assert %{"wonderland" => five_days_weather()} == state
  end

  test "Forecastr.forecast/3 hits the cache when it's pre-warmed for today" do
    assert :ok = Forecastr.Cache.set(:today, "wonderland", today_weather())
    # It does hit the cache, not the backend, the backend is not configured
    output = capture_io(fn -> Forecastr.forecast(:today, "wonderland") end)
    assert output =~ "Wonderland"
  end

  test "Forecastr.forecast/3 hits the cache when it's pre-warmed for five days" do
    assert :ok = Forecastr.Cache.set(:in_five_days, "wonderland", five_days_weather())

    # It does hit the cache, not the backend, the backend is not configured
    output = capture_io(fn -> Forecastr.forecast(:in_five_days, "wonderland") end)
    assert output =~ "Wonderland"
  end

  def today_weather do
    %{
      "name" => "Wonderland",
      "sys" => %{"country" => "Wonderland"},
      "coord" => %{"lat" => 52.52, "lon" => 13.39},
      "weather" => [%{"description" => "sunny", "id" => 200}],
      "main" => %{"temp" => 7, "temp_max" => 7, "temp_min" => 7}
    }
  end

  def five_days_weather do
    %{
      "city" => %{
        "coord" => %{"lat" => 52.52, "lon" => 13.39},
        "country" => "Wonderland",
        "name" => "Wonderland"
      },
      "list" => []
    }
  end
end
