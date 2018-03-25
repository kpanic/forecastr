defmodule Forecastr.HTTP do
  use HTTPoison.Base

  def process_url(url), do: "http://" <> url
  def process_request_options(options), do: Keyword.merge(options, [params: Map.merge(options[:params], %{APPID: Application.fetch_env!(:forecastr, :appid)})])
end
