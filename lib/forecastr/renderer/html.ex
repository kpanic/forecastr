defmodule Forecastr.Renderer.HTML do
  @moduledoc """
  HTML renderer

  Takes advantage of the ASCII renderer and ascii art placeholders to render
  HTML
  """

  @spec render(map(), units :: atom()) :: list()
  def render(map, units) do
    map
    |> Forecastr.Renderer.ASCII.render(:html, units)
  end
end
