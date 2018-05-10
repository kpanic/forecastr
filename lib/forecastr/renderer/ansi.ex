defmodule Forecastr.Renderer.ANSI do
  @moduledoc """
  ANSI renderer

  Takes advantage of the ASCII renderer and ascii art placeholders to render
  ANSI escape sequences
  """

  @spec render(map()) :: list()
  def render(map) do
    map
    |> Forecastr.Renderer.ASCII.render(:ansi)
  end
end
