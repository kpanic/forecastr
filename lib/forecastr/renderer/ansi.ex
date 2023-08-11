defmodule Forecastr.Renderer.ANSI do
  @moduledoc """
  ANSI renderer

  Takes advantage of the ASCII renderer and ascii art placeholders to render
  ANSI escape sequences
  """

  @spec render(map(), units :: atom()) :: list()
  def render(map, units), do: Forecastr.Renderer.ASCII.render(map, :ansi, units)
end
