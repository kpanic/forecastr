defmodule Forecastr.HTTP do
  use HTTPoison.Base

  @spec process_url(String.t()) :: String.t()
  def process_url(url), do: "http://" <> url

  @spec process_request_options(Keyword.t()) :: Keyword.t()
  def process_request_options(options),
    do:
      Keyword.merge(
        options,
        params: Map.merge(options[:params], %{APPID: Application.fetch_env!(:forecastr, :appid)})
      )
end
