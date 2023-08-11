defmodule Forecastr.OWM.HTTP do
  @moduledoc false

  use HTTPoison.Base

  def process_request_url(url), do: "https://" <> url

  def process_request_options(options),
    do:
      Keyword.merge(
        options,
        params: Map.merge(options[:params], %{APPID: Application.fetch_env!(:forecastr, :appid)})
      )
end
