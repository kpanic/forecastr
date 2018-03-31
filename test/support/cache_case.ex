defmodule Forecastr.CacheCase do
  use ExUnit.CaseTemplate

  @moduledoc false

  setup do
    Application.ensure_all_started(:forecastr)
    Forecastr.Cache.Worker.start_link(name: Forecastr.Cache.Today)
    Forecastr.Cache.Worker.start_link(name: Forecastr.Cache.InFiveDays)

    on_exit(fn ->
      assert GenServer.stop(Forecastr.Cache.Today) == :ok
      assert GenServer.stop(Forecastr.Cache.InFiveDays) == :ok
      Application.stop(:forecastr)
    end)
    :ok
  end
end
