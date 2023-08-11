defmodule Forecastr.Renderer.JSON do
  @moduledoc """
  JSON "renderer".
  """

  @spec render(map(), units :: atom()) :: map()
  def render(forecast, _units) do
    forecast
  end
end
