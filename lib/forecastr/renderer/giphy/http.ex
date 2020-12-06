defmodule Forecastr.Renderer.Giphy.HTTP do
  @number_of_gifs_to_dig 50
  @moduledoc false
  @api_key Application.get_env(:forecastr, :giphy_api_key)

  def search(keyword) do
    query =
      URI.encode_query(%{
        q: keyword,
        api_key: @api_key,
        limit: @number_of_gifs_to_dig
      })

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
