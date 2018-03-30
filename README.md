# Forecastr

Forecastr is an open source Weather API wrapper for OpenWeatherMap.

Forecastr is an Elixir flavour of http://wttr.in that talks directly to OpenWeatherMap.
Aim of the project is to provide a website similar to wttr.in written entirely in elixir

**Project status: initial. (very pre-alphaish)**

**NOTE**
If you want to play with this project you have to obtain an api key from http://openweathermap.org/
and:

```bash
export OWM_API_KEY=YOUR_API_KEY
```

Sample output for today's forecast
```
iex(1)> Forecastr.forecast(:today, "Berlin")
Weather report: Berlin, DE
lat: 52.52, lon: 13.39

┌──────────────────────────────┐
│   \   /                      │
│    .-.    clear sky          │
│ ‒ (   ) ‒ 3 °C               │
│    `-᾿    max: 3 °C          │
│   /   \   min: 3 °C          │
│                              │
└──────────────────────────────┘
```

Sample output with the ASCII renderer:

```
iex(1)> Forecastr.forecast(:in_five_days, "Lima")
Weather report: Lima, PE
lat: -12.0622, lon: -77.0366

┌────────────┐
│ 2018-03-30 │
└────────────┘
┌─────────────────────────────┬─────────────────────────────┬──────────────────────────────┬──────────────────────────────┐
│ Morning                     ╎ Noon                        ╎ Afternoon                    ╎ Evening                      │
│   \  /      few clouds      ╎   \  /      few clouds      ╎   \   /                      ╎   \   /                      │
│ _ /"".-.    13.05 °C        ╎ _ /"".-.    14.14 °C        ╎    .-.    clear sky          ╎    .-.    clear sky          │
│   \_(   ).  max: 13.25 °C   ╎   \_(   ).  max: 14.29 °C   ╎ ‒ (   ) ‒ 22.03 °C           ╎ ‒ (   ) ‒ 21.15 °C           │
│   /(___(__) min: 13.05 °C   ╎   /(___(__) min: 14.14 °C   ╎    `-᾿    max: 22.08 °C      ╎    `-᾿    max: 21.15 °C      │
│                             ╎                             ╎   /   \   min: 22.03 °C      ╎   /   \   min: 21.15 °C      │
│                             ╎                             ╎                              ╎                              │
└─────────────────────────────┴─────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
┌────────────┐
│ 2018-03-31 │
└────────────┘
┌─────────────────────────────┬──────────────────────────────┬──────────────────────────────┬──────────────────────────────┬──────────────────────────────┐
│ Night                       ╎ Morning                      ╎ Noon                         ╎ Afternoon                    ╎ Evening                      │
│   \  /      few clouds      ╎   \   /                      ╎   \   /                      ╎   \   /                      ╎   \   /                      │
│ _ /"".-.    18 °C           ╎    .-.    clear sky          ╎    .-.    clear sky          ╎    .-.    clear sky          ╎    .-.    clear sky          │
│   \_(   ).  max: 18 °C      ╎ ‒ (   ) ‒ 12.56 °C           ╎ ‒ (   ) ‒ 12.87 °C           ╎ ‒ (   ) ‒ 21.88 °C           ╎ ‒ (   ) ‒ 20.75 °C           │
│   /(___(__) min: 18 °C      ╎    `-᾿    max: 12.56 °C      ╎    `-᾿    max: 12.87 °C      ╎    `-᾿    max: 21.88 °C      ╎    `-᾿    max: 20.75 °C      │
│                             ╎   /   \   min: 12.56 °C      ╎   /   \   min: 12.87 °C      ╎   /   \   min: 21.88 °C      ╎   /   \   min: 20.75 °C      │
│                             ╎                              ╎                              ╎                              ╎                              │
└─────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
┌────────────┐
│ 2018-04-01 │
└────────────┘
┌──────────────────────────────┬──────────────────────────────┬──────────────────────────────┬──────────────────────────────┬──────────────────────────────┐
│ Night                        ╎ Morning                      ╎ Noon                         ╎ Afternoon                    ╎ Evening                      │
│   \   /                      ╎   \   /                      ╎   \   /                      ╎   \   /                      ╎   \   /                      │
│    .-.    clear sky          ╎    .-.    clear sky          ╎    .-.    clear sky          ╎    .-.    clear sky          ╎    .-.    clear sky          │
│ ‒ (   ) ‒ 17.09 °C           ╎ ‒ (   ) ‒ 11.42 °C           ╎ ‒ (   ) ‒ 12.17 °C           ╎ ‒ (   ) ‒ 21.52 °C           ╎ ‒ (   ) ‒ 20.62 °C           │ 
│    `-᾿    max: 17.09 °C      ╎    `-᾿    max: 11.42 °C      ╎    `-᾿    max: 12.17 °C      ╎    `-᾿    max: 21.52 °C      ╎    `-᾿    max: 20.62 °C      │
│   /   \   min: 17.09 °C      ╎   /   \   min: 11.42 °C      ╎   /   \   min: 12.17 °C      ╎   /   \   min: 21.52 °C      ╎   /   \   min: 20.62 °C      │
│                              ╎                              ╎                              ╎                              ╎                              │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
┌────────────┐
│ 2018-04-02 │
└────────────┘
┌──────────────────────────────┬────────────────────────────────┬───────────────────────────────┬───────────────────────────────┬───────────────────────────────────┐
│ Night                        ╎ Morning                        ╎ Noon                          ╎ Afternoon                     ╎ Evening                           │
│   \   /                      ╎    .--.     broken clouds      ╎ _`/"".-.                      ╎ _`/"".-.                      ╎    .--.     scattered clouds      │
│    .-.    clear sky          ╎ .-(    ).   12.9 °C            ╎  ,\_(   ).  light rain        ╎  ,\_(   ).  light rain        ╎ .-(    ).   19.67 °C              │
│ ‒ (   ) ‒ 17.08 °C           ╎ (___.__)__) max: 12.9 °C       ╎  /(___(__)  14.13 °C          ╎  /(___(__)  20.12 °C          ╎ (___.__)__) max: 19.67 °C         │
│    `-᾿    max: 17.08 °C      ╎             min: 12.9 °C       ╎    ʻ ʻ ʻ ʻ  max: 14.13 °C     ╎    ʻ ʻ ʻ ʻ  max: 20.12 °C     ╎             min: 19.67 °C         │
│   /   \   min: 17.08 °C      ╎                                ╎    ʻ ʻ ʻ ʻ  min: 14.13 °C     ╎    ʻ ʻ ʻ ʻ  min: 20.12 °C     ╎                                   │
│                              ╎                                ╎                               ╎                               ╎                                   │
└──────────────────────────────┴────────────────────────────────┴───────────────────────────────┴───────────────────────────────┴───────────────────────────────────┘
┌────────────┐
│ 2018-04-03 │
└────────────┘
┌─────────────────────────────┬─────────────────────────────┬──────────────────────────────┬───────────────────────────────────┬───────────────────────────────┐
│ Night                       ╎ Morning                     ╎ Noon                         ╎ Afternoon                         ╎ Evening                       │
│   \  /      few clouds      ╎   \  /      few clouds      ╎   \   /                      ╎    .--.     scattered clouds      ╎ _`/"".-.                      │
│ _ /"".-.    16.83 °C        ╎ _ /"".-.    12.01 °C        ╎    .-.    clear sky          ╎ .-(    ).   21.27 °C              ╎  ,\_(   ).  light rain        │
│   \_(   ).  max: 16.83 °C   ╎   \_(   ).  max: 12.01 °C   ╎ ‒ (   ) ‒ 12.74 °C           ╎ (___.__)__) max: 21.27 °C         ╎  /(___(__)  19.7 °C           │
│   /(___(__) min: 16.83 °C   ╎   /(___(__) min: 12.01 °C   ╎    `-᾿    max: 12.74 °C      ╎             min: 21.27 °C         ╎    ʻ ʻ ʻ ʻ  max: 19.7 °C      │
│                             ╎                             ╎   /   \   min: 12.74 °C      ╎                                   ╎    ʻ ʻ ʻ ʻ  min: 19.7 °C      │
│                             ╎                             ╎                              ╎                                   ╎                               │
└─────────────────────────────┴─────────────────────────────┴──────────────────────────────┴───────────────────────────────────┴───────────────────────────────┘ 
┌────────────┐
│ 2018-04-04 │
└────────────┘
┌─────────────────────────────┐
│ Night                       │
│   \  /      few clouds      │
│ _ /"".-.    16.89 °C        │
│   \_(   ).  max: 16.89 °C   │
│   /(___(__) min: 16.89 °C   │
│                             │
└─────────────────────────────┘
[...]
```


> "*All the ducks are swimming in the water
> Fal de ral de ral do*" (Lemon Jelly cit.)

![duck with sunglasses](duck_with_sunglasses.jpg)

# TODO
- [X] Travis
- [ ] Tests!
- [ ] Integrate https://forecast.io as a backend?
- [ ] HTML renderer
- [ ] JSON renderer
- [ ] Correct ASCII Art for the renderers that supports that (In progress)

# Thank yous

* The https://wttr.in project for inspiration
* [wego]:(https://github.com/schachmat/wego) for the amazing ASCII art

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

