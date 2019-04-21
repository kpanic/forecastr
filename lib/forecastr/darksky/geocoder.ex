defmodule Forecastr.Darksky.Geocoder do
  @moduledoc false

  @endpoint "https://nominatim.openstreetmap.org"
  @format "json"

  def geocode(address, additional_params \\ []) do
    default_params = [q: address, format: @format, addressdetails: 1]

    geocode_with_osm("/search", default_params ++ additional_params)
    |> parse_request()
  end

  defp parse_request(%HTTPoison.Response{body: body}) do
    Poison.decode!(body)
  end

  defp geocode_with_osm(path, params) do
    params = Enum.into(params, %{})
    HTTPoison.get!(@endpoint <> path, [], params: params)
  end
end
