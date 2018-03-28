defmodule Forecastr.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Supervisor.child_spec({Forecastr.Cache.Worker, [name: Forecastr.Cache.Today]}, id: Forecastr.Cache.Today),
      Supervisor.child_spec({Forecastr.Cache.Worker, [name: Forecastr.Cache.InFiveDays]}, id: Forecastr.Cache.InFiveDays)
    ]

    opts = [strategy: :one_for_one, name: Forecastr.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
