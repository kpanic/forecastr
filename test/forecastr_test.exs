defmodule ForecastrTest do
  use Forecastr.CacheCase

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
    assert {:error, :not_found} = Forecastr.forecast(:today, "")
    assert {:error, :not_found} = Forecastr.forecast(:in_five_days, "")
  end

  test "Forecast for a city today" do
    Application.put_env(:forecastr, :backend, OWMBackendToday)
    assert {:ok, response} = Forecastr.forecast(:today, "Wonderland")
    assert Enum.count(response) > 0
  end

  test "Forecast for a city returns an error" do
    Application.put_env(:forecastr, :backend, OWMBackendError)
    assert {:error, _} = Forecastr.forecast(:today, "Mars")
    assert {:error, _} = Forecastr.forecast(:in_five_days, "Hale-Bopp")
  end

  test "Forecast for a city in 5 days" do
    Application.put_env(:forecastr, :backend, OWMBackendFiveDays)
    assert {:ok, response} = Forecastr.forecast(:in_five_days, "Wonderland")
    assert Enum.count(response) > 0
  end

  test "Forecastr.forecast cache correctly :today" do
    Application.put_env(:forecastr, :backend, OWMBackendToday)
    assert {:ok, _response} = Forecastr.forecast(:today, "Wonderland")
    state = :sys.get_state(Forecastr.Cache.Today)

    assert %{"wonderland" => today_weather()} == state
  end

  test "Forecastr.forecast cache correctly :in_five_days" do
    Application.put_env(:forecastr, :backend, OWMBackendFiveDays)
    assert {:ok, _response} = Forecastr.forecast(:in_five_days, "Wonderland")
    state = :sys.get_state(Forecastr.Cache.InFiveDays)

    assert %{"wonderland" => five_days_weather()} == state
  end

  test "Forecastr.forecast hits the cache when it's pre-warmed for today" do
    assert :ok = Forecastr.Cache.set(:today, "wonderland", today_weather())
    # It does hit the cache, not the backend, the backend is not configured
    assert {:ok, response} = Forecastr.forecast(:today, "wonderland")
    assert Enum.count(response) > 0
  end

  test "Forecastr.forecast hits the cache when it's pre-warmed for five days" do
    assert :ok = Forecastr.Cache.set(:in_five_days, "wonderland", five_days_weather())

    # It does hit the cache, not the backend, the backend is not configured
    assert {:ok, response} = Forecastr.forecast(:in_five_days, "wonderland")
    assert Enum.count(response) > 0
  end

  test "Forecast.forecast uses the html renderer" do
    Application.put_env(:forecastr, :backend, OWMBackendFiveDays)
    assert {:ok, [response | _rest]} = Forecastr.forecast(:in_five_days, "wonderland", %{}, Forecastr.Renderer.HTML)
    assert response =~ "<head>"
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
