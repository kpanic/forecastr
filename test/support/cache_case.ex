defmodule Forecastr.CacheCase do
  use ExUnit.CaseTemplate

  @moduledoc false

  setup do
    Application.ensure_all_started(:forecastr)
    Forecastr.Cache.Worker.start_link(name: Forecastr.Cache.Today)
    Forecastr.Cache.Worker.start_link(name: Forecastr.Cache.NextDays)

    on_exit(fn ->
      assert GenServer.stop(Forecastr.Cache.Today) == :ok
      assert GenServer.stop(Forecastr.Cache.NextDays) == :ok
      Application.stop(:forecastr)
    end)

    :ok
  end
end
