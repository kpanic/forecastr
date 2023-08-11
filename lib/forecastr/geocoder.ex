defmodule Forecastr.Geocoder do
  @moduledoc false

  @endpoint "https://nominatim.openstreetmap.org"
  @format "json"

  def geocode(address, additional_params \\ []) do
    default_params = [q: address, format: @format, addressdetails: 1]

    "/search"
    |> geocode_with_osm(default_params ++ additional_params)
    |> parse_request()
    |> Enum.at(0, %{})
    |> put_location()
  end

  defp parse_request(%HTTPoison.Response{body: body}) do
    Poison.decode!(body)
  end

  defp geocode_with_osm(path, params) do
    params = Enum.into(params, %{})
    HTTPoison.get!(@endpoint <> path, [], params: params)
  end

  defp put_location(%{"display_name" => location} = body),
    do: put_in(body, ["address", "city"], location)
end
