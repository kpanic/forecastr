defmodule Forecastr.Darksky.Geocoder do
  use HTTPoison.Base

  @endpoint "https://nominatim.openstreetmap.org"
  @format "json"

  def geocode(address, additional_params \\ []) do
    default_params = [q: address, format: @format, addressdetails: 1]

    request("/search", default_params ++ additional_params)
    |> parse_request()
  end

  defp parse_request(%HTTPoison.Response{body: body}) do
    Poison.decode!(body)
  end

  def request(path, params) do
    params = Enum.into(params, %{})
    get!(@endpoint <> path, [], params: params)
  end
end
