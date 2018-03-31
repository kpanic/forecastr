defmodule Forecastr.Cache.WorkerTest do
  use ExUnit.Case

  doctest Forecastr

  @response_today %{
    "base" => "stations",
    "clouds" => %{"all" => 40},
    "cod" => 200,
    "coord" => %{"lat" => 52.52, "lon" => 13.39},
    "dt" => 1_522_081_200,
    "id" => 2_950_159,
    "main" => %{
      "humidity" => 65,
      "pressure" => 1014,
      "temp" => 280.15,
      "temp_max" => 280.15,
      "temp_min" => 280.15
    },
    "name" => "Berlin",
    "sys" => %{
      "country" => "DE",
      "id" => 4892,
      "message" => 0.004,
      "sunrise" => 1_522_040_019,
      "sunset" => 1_522_085_472,
      "type" => 1
    },
    "visibility" => 10_000,
    "weather" => [
      %{"description" => "scattered clouds", "icon" => "03d", "id" => 802, "main" => "Clouds"}
    ],
    "wind" => %{"deg" => 320, "speed" => 4.6}
  }

  @cache_key "foo_bar_baz"

  setup do
    Forecastr.Cache.Worker.start_link(name: Forecastr.Cache.Today)
    Forecastr.Cache.Worker.start_link(name: Forecastr.Cache.InFiveDays)

    on_exit(fn ->
      GenServer.stop(Forecastr.Cache.Today)
      GenServer.stop(Forecastr.Cache.InFiveDays)
    end)
  end

  test "caching works for :today" do
    assert :ok == Forecastr.Cache.Worker.set(Forecastr.Cache.Today, @cache_key, @response_today)
    assert Forecastr.Cache.Worker.get(Forecastr.Cache.Today, @cache_key) == @response_today

    assert is_nil(Forecastr.Cache.Worker.get(Forecastr.Cache.InFiveDays, @cache_key)) == true
  end

  test "caching works for :in_five_days" do
    assert :ok ==
             Forecastr.Cache.Worker.set(Forecastr.Cache.InFiveDays, @cache_key, @response_today)

    assert Forecastr.Cache.Worker.get(Forecastr.Cache.InFiveDays, @cache_key) == @response_today

    assert is_nil(Forecastr.Cache.Worker.get(Forecastr.Cache.Today, @cache_key)) == true
  end
end
