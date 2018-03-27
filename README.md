# Forecastr

Forecastr is an open source Weather API wrapper for OpenWeatherMap.

Forecastr is an Elixir flavour of http://wttr.in that talks directly to OpenWeatherMap.
Aim of the project is to provide a website similar to wttr.in written entirely in elixir

**NOTE**: If you want to play with this project you have to obtain an api key from http://openweathermap.org/

**Project status: initial. (very pre-alphaish)**

Sample output with the ASCII renderer:

```
iex(1)> Forecastr.forecast(:in_five_days, "Lima")
Weather report: Lima, PE
lat: -12.0622, lon: -77.0366

┌────────────┐
│ 2018-03-25 │
└────────────┘
┌────────────────────────────┐
│ Evening                    │
│   \  /       light rain    │
│ _ /''.-.     20.18 °C      │
│   \_(   ).   max: 21.23 °C │
│   /(___(__)  min: 20.18 °C │
│                            │
└────────────────────────────┘
┌────────────┐
│ 2018-03-26 │
└────────────┘
┌────────────────────────────┬────────────────────────────┬────────────────────────────┬────────────────────────────┬────────────────────────────┐
│ Night                      ╎ Morning                    ╎ Noon                       ╎ Afternoon                  ╎ Evening                    │
│   \  /       light rain    ╎   \  /       light rain    ╎   \  /       light rain    ╎   \  /       light rain    ╎   \  /       light rain    │
│ _ /''.-.     17.36 °C      ╎ _ /''.-.     16.12 °C      ╎ _ /''.-.     16.43 °C      ╎ _ /''.-.     21.44 °C      ╎ _ /''.-.     20.43 °C      │
│   \_(   ).   max: 18.15 °C ╎   \_(   ).   max: 16.12 °C ╎   \_(   ).   max: 16.43 °C ╎   \_(   ).   max: 21.44 °C ╎   \_(   ).   max: 20.43 °C │
│   /(___(__)  min: 17.36 °C ╎   /(___(__)  min: 16.12 °C ╎   /(___(__)  min: 16.43 °C ╎   /(___(__)  min: 21.44 °C ╎   /(___(__)  min: 20.43 °C │
│                            ╎                            ╎                            ╎                            ╎                            │
└────────────────────────────┴────────────────────────────┴────────────────────────────┴────────────────────────────┴────────────────────────────┘
┌────────────┐
│ 2018-03-27 │
└────────────┘
┌────────────────────────────┬───────────────────────────────┬────────────────────────────┬────────────────────────────┬───────────────────────────┐
│ Night                      ╎ Morning                       ╎ Noon                       ╎ Afternoon                  ╎ Evening                   │
│   \  /       light rain    ╎   \  /       scattered clouds ╎   \  /       broken clouds ╎   \  /       few clouds    ╎   \  /       light rain   │
│ _ /''.-.     18.02 °C      ╎ _ /''.-.     14.18 °C         ╎ _ /''.-.     15.2 °C       ╎ _ /''.-.     22.38 °C      ╎ _ /''.-.     21.1 °C      │
│   \_(   ).   max: 18.02 °C ╎   \_(   ).   max: 14.18 °C    ╎   \_(   ).   max: 15.2 °C  ╎   \_(   ).   max: 22.38 °C ╎   \_(   ).   max: 21.1 °C │
│   /(___(__)  min: 18.02 °C ╎   /(___(__)  min: 14.18 °C    ╎   /(___(__)  min: 15.2 °C  ╎   /(___(__)  min: 22.38 °C ╎   /(___(__)  min: 21.1 °C │
│                            ╎                               ╎                            ╎                            ╎                           │
└────────────────────────────┴───────────────────────────────┴────────────────────────────┴────────────────────────────┴───────────────────────────┘

[...]
```


> "*All the ducks are swimming in the water
> Fal de ral de ral do*" (Lemon Jelly cit.)

![duck with sunglasses](duck_with_sunglasses.jpg)

# TODO
 [ ] Tests!
 [ ] Travis
 [ ] Integrate https://forecast.io as a backend?
 [ ] HTML renderer
 [ ] JSON renderer
 [ ] Correct ASCII Art for the renderers that supports that

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `forecastr` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:forecastr, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/forecastr](https://hexdocs.pm/forecastr).

