defmodule Forecastr.Renderer.Colours do
  @moduledoc """
  Return the right colour sequence given an output_type such as (:ascii, :ansi, :png)
  """

  alias IO.ANSI

  def bright_yellow(:ascii), do: ""

  def bright_yellow(:ansi) do
    [ANSI.bright(), ANSI.yellow()]
  end

  def bright_yellow(:png) do
    [~S(<span foreground="yellow">)]
  end

  def bright_yellow(:html) do
    [~S(<span style="color: yellow">)]
  end

  def yellow(:ascii), do: ""

  def yellow(:ansi) do
    [ANSI.yellow()]
  end

  def yellow(:png) do
    [~S(<span foreground="yellow">)]
  end

  def yellow(:html) do
    [~S(<span style="color: yellow">)]
  end

  def magenta(:ascii), do: ""

  def magenta(:ansi) do
    [ANSI.light_magenta()]
  end

  def magenta(:png) do
    [~S(<span foreground="magenta">)]
  end

  def white(:ascii), do: ""

  def white(:ansi) do
    [ANSI.white()]
  end

  def white(:png) do
    [~S(<span foreground="white">)]
  end

  def white(:html) do
    [~S(<span style="color: white">)]
  end

  def light_white(:ascii), do: ""

  def light_white(:ansi) do
    [ANSI.light_white()]
  end

  def light_white(:png) do
    [~S(<span foreground="white">)]
  end

  def light_white(:html) do
    [~S(<span style="color: white">)]
  end

  def blue(:ascii), do: ""

  def blue(:ansi) do
    [ANSI.blue()]
  end

  def blue(:png) do
    [~S(<span foreground="blue">)]
  end

  def blue(:html) do
    [~S(<span style="color: blue">)]
  end

  def normal(:ascii), do: ""

  def normal(:ansi) do
    [ANSI.normal()]
  end

  def normal(:png) do
    [~S(<span foreground="gray">)]
  end

  def normal(:html) do
    [~S(<span style="color: gray">)]
  end

  def reset(:ascii), do: ""

  def reset(:ansi) do
    ANSI.reset()
  end

  def reset(:png) do
    "</span>"
  end

  def reset(:html) do
    "</span>"
  end
end
