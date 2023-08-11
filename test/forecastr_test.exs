defmodule ForecastrTest do
  use Forecastr.CacheCase

  @moduletag :capture_log

  defmodule BackendToday do
    def weather(_when_to_forecast, _city, _params) do
      {:ok, ForecastrTest.today_weather()}
    end

    def normalize(pass_through) do
      {:ok, pass_through}
    end
  end

  defmodule BackendNextDays do
    def weather(_when_to_forecast, _city, _params) do
      {:ok, ForecastrTest.five_days_weather()}
    end

    def normalize(pass_through) do
      {:ok, pass_through}
    end
  end

  defmodule BackendError do
    def weather(_when_to_forecast, _city, _params) do
      {:error, :not_found}
    end

    def normalize(pass_through) do
      {:ok, pass_through}
    end
  end

  test "Forecast with an empty string" do
    assert {:error, :not_found} = Forecastr.forecast(:today, "")
    assert {:error, :not_found} = Forecastr.forecast(:next_days, "")
  end

  describe "forecast for today" do
    setup do
      original_backend = Application.get_env(:forecastr, :backend)
      Application.put_env(:forecastr, :backend, BackendToday)

      on_exit(fn ->
        Application.put_env(:forecastr, :backend, original_backend)
      end)
    end

    test "city" do
      assert {:ok, response} = Forecastr.forecast(:today, "Wonderland")
      assert Enum.count(response) > 0
    end

    test "cache correctly :today" do
      assert {:ok, _response} = Forecastr.forecast(:today, "Wonderland")

      [state] = :ets.tab2list(Forecastr.Cache.Today)

      assert {"wonderland", today_weather()} == state
    end
  end

  describe "forecast next days" do
    setup do
      original_backend = Application.get_env(:forecastr, :backend)
      Application.put_env(:forecastr, :backend, BackendNextDays)

      on_exit(fn ->
        Application.put_env(:forecastr, :backend, original_backend)
      end)
    end

    test "Forecast for a city in 5 days" do
      assert {:ok, response} = Forecastr.forecast(:next_days, "Wonderland")
      assert Enum.count(response) > 0
    end

    test "Forecastr.forecast cache correctly :next_days" do
      assert {:ok, _response} = Forecastr.forecast(:next_days, "Wonderland")
      [state] = :ets.tab2list(Forecastr.Cache.NextDays)

      assert {"wonderland", five_days_weather()} == state
    end
  end

  test "Forecast for a city returns an error" do
    original_backend = Application.get_env(:forecastr, :backend)
    Application.put_env(:forecastr, :backend, BackendError)
    assert {:error, _} = Forecastr.forecast(:today, "Mars")
    assert {:error, _} = Forecastr.forecast(:next_days, "Hale-Bopp")

    on_exit(fn ->
      Application.put_env(:forecastr, :backend, original_backend)
    end)
  end

  test "Forecastr.forecast hits the cache when it's pre-warmed for today" do
    assert :ok = Forecastr.Cache.set(:today, "wonderland", today_weather())
    # It does hit the cache, not the backend, the backend is not configured
    assert {:ok, response} = Forecastr.forecast(:today, "wonderland")
    assert Enum.count(response) > 0
  end

  test "Forecastr.forecast hits the cache when it's pre-warmed for five days" do
    assert :ok = Forecastr.Cache.set(:next_days, "wonderland", five_days_weather())

    # It does hit the cache, not the backend, the backend is not configured
    assert {:ok, response} = Forecastr.forecast(:next_days, "wonderland")
    assert Enum.count(response) > 0
  end

  def today_weather do
    %{
      "name" => "Wonderland",
      "country" => "Wonderland",
      "coordinates" => %{"lat" => 52.52, "lon" => 13.39},
      "description" => "sunny",
      "id" => 200,
      "temp" => 7,
      "temp_max" => 7,
      "temp_min" => 7
    }
  end

  def five_days_weather do
    %{
      "coordinates" => %{"lat" => 52.52, "lon" => 13.39},
      "country" => "Wonderland",
      "name" => "Wonderland",
      "list" => []
    }
  end
end
