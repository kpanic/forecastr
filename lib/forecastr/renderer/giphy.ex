defmodule Forecastr.Renderer.Giphy do
  @moduledoc """
  Giphy renderer
  """

  @relevant_times %{
    "09:00:00" => "Morning",
    "12:00:00" => "Noon",
    "18:00:00" => "Afternoon",
    "21:00:00" => "Evening",
    "00:00:00" => "Night"
  }

  alias __MODULE__

  defmodule HTTP do
    @moduledoc false
    @api_key Application.get_env(:forecastr, :giphy_api_key)

    def search(keyword) do
      query = URI.encode_query(%{q: keyword <> " forecast", api_key: @api_key})
      giphy_url = "https://api.giphy.com/v1/gifs/search?#{query}"

      giphy_url
      |> HTTPoison.get!()
      |> Map.get(:body)
      |> Poison.decode!()
      |> extract_gif_urls()
    end

    defp extract_gif_urls(%{"data" => gifs}) do
      Enum.map(gifs, fn gif ->
        %{"images" => %{"fixed_height" => %{"url" => url}}} = gif
        String.replace(url, ~r/(.*)(media\d+)(.*)/, "\\1i\\3")
      end)
    end
  end

  @spec render(map()) :: map()
  def render(%{"description" => description} = map) do
    map
    |> Map.put("giphy_pic", Enum.random(Giphy.HTTP.search(description)))
  end

  def render(%{"list" => forecasts} = map) do
    %{map | "list" => giphy(forecasts)}
  end

  defp giphy(forecasts) do
    forecasts
    |> Enum.group_by(& &1["description"])
    |> Task.async_stream(fn {description, forecasts} ->
      giphy_pics = Forecastr.Renderer.Giphy.HTTP.search("#{description}")

      Enum.map(forecasts, fn forecast ->
        Map.put(forecast, "giphy_pic", Enum.random(giphy_pics))
      end)
    end)
    |> Enum.to_list()
    |> Keyword.values()
    |> List.flatten()
    |> Enum.sort_by(& &1["dt_txt"])
    |> extract_relevant_times()
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
end
