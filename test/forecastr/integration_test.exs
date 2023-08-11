defmodule Forecastr.IntegrationTest do
  use Forecastr.CacheCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start()
    :ok
  end

  describe "Forecastr.forecast/3" do
    setup do
      ExVCR.Config.filter_url_params(true)
      ExVCR.Config.filter_request_headers("X-Cache-Key")
      
      Application.put_env(:forecastr, :backend, Forecastr.OWM)
      :ok
    end

    test "success" do
      use_cassette "successfully gets weather for today" do
        assert {:ok,
                %{
                  "coordinates" => %{"lat" => 52.517, "lon" => 13.3889},
                  "country" => "DE",
                  "description" => _,
                  "id" => 801,
                  "name" => "Berlin, Deutschland",
                  "temp" => _,
                  "temp_max" => _,
                  "temp_min" => _
                }} = Forecastr.forecast(:today, "Berlin", renderer: Forecastr.Renderer.JSON)
      end

      use_cassette "successfully gets weather for next days" do
        assert {:ok,
                %{
                  "coordinates" => %{"lat" => 52.517, "lon" => 13.3889},
                  "country" => "DE",
                  "list" => forecasts,
                  # The OWM API returns this place in Berlin instead of Berlin 🤷
                  "name" => "Alt-Kölln"
                }} = Forecastr.forecast(:next_days, "Berlin, Germany", renderer: Forecastr.Renderer.JSON)

        assert is_list(forecasts)
      end
    end

    test "does not find the place" do
      use_cassette "place not found" do
        assert {:error, :place_not_found} =
                 Forecastr.forecast(:today, "The sunny side of the street")
      end
    end
  end
end
