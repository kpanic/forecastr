defmodule Forecastr.Renderer.HTML do
  @moduledoc """
  HTML renderer

  Takes advantage of the ASCII renderer and ascii art placeholders to render
  HTML
  """

  @spec render(map()) :: list()
  def render(map) do
    map
    |> Forecastr.Renderer.ASCII.render(:html)
  end
end
