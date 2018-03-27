defmodule Forecastr.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Forecastr.Cache.Today, []},
      {Forecastr.Cache.InFiveDays, []}
    ]

    opts = [strategy: :one_for_one, name: Forecastr.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
