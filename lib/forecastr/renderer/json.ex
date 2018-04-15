defmodule Forecastr.Renderer.JSON do
  @moduledoc """
  JSON "renderer".
  Currently it just returns what the OWM API will return
  """

  @spec render(map()) :: map()
  def render(forecast) do
    forecast
  end
end
