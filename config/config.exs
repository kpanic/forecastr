use Mix.Config

config :forecastr,
  appid: System.get_env("FORECASTR_API_KEY"),
  backend: Forecastr.Darksky,
  # 10 minutes of caching time to live
  ttl: 10 * 60_000
