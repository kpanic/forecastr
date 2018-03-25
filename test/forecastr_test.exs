defmodule ForecastrTest do
  use ExUnit.Case
  doctest Forecastr

  test "greets the world" do
    assert Forecastr.hello() == :world
  end
end
