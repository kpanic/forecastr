defmodule Forecastr.Renderer.Colours do
  alias IO.ANSI

  def bright_yellow(:ansi) do
    [ANSI.bright(), ANSI.yellow()]
  end

  def bright_yellow(:png) do
    [~S(<span foreground="yellow">)]
  end

  def yellow(:ansi) do
    [ANSI.yellow()]
  end

  def yellow(:png) do
    [~S(<span foreground="yellow">)]
  end

  def magenta(:ansi) do
    [ANSI.light_magenta()]
  end

  def magenta(:png) do
    [~S(<span foreground="magenta">)]
  end

  def white(:ansi) do
    [ANSI.white()]
  end

  def white(:png) do
    [~S(<span foreground="white">)]
  end

  def light_white(:ansi) do
    [ANSI.light_white()]
  end

  def light_white(:png) do
    [~S(<span foreground="white">)]
  end

  def blue(:ansi) do
    [ANSI.blue()]
  end

  def blue(:png) do
    [~S(<span foreground="blue">)]
  end

  def reset(:ansi) do
    [ANSI.reset()]
  end

  def reset(:png) do
    ["</span>"]
  end
end
