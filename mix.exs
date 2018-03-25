defmodule Forecastr.MixProject do
  use Mix.Project

  def project do
    [
      app: :forecastr,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Forecastr.Application, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"}
    ]
  end
end
