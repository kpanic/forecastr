defmodule Forecastr.Renderer.Colours do
  alias IO.ANSI

  def bright_yellow(:ansi) do
    [ANSI.bright(), ANSI.yellow()]
  end

  def reset(:ansi) do
    [ANSI.reset()]
  end
end
