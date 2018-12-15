# Forecastr ![Build Status](https://secure.travis-ci.org/kpanic/forecastr.png?branch=master "Build Status") ![Package Version](https://img.shields.io/hexpm/v/forecastr.svg "Package Version") ![License](https://img.shields.io/hexpm/l/forecastr.svg "License")


Forecastr is an open source Weather API wrapper for OpenWeatherMap.

Forecastr is an Elixir flavour of http://wttr.in that talks directly to OpenWeatherMap.
Aim of the project is to provide a website similar to wttr.in written entirely in elixir

**Project status: initial. (very pre-alphaish)**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `forecastr` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:forecastr, "~> 0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/forecastr](https://hexdocs.pm/forecastr).


**NOTE**
If you want to play with this project you have to obtain an api key from http://openweathermap.org/
and:

```bash
export OWM_API_KEY=YOUR_API_KEY
```

Also put in your `config/config.exs`

```elixir
config :forecastr,
  appid: System.get_env("OWM_API_KEY"),
  backend: Forecastr.OWM,
  # 10 minutes by default per OWM policy
  ttl: 10 * 60_000
```

Samples of output for today's forecast

```elixir
Forecastr.forecast(:today, "lima", %{units: :metric}, Forecastr.Renderer.PNG)
```

![today](today.png)
![berlin](berlin.png)

Sample output for 5 days:


![in 5 days](in_five_days.png)

> "*All the ducks are swimming in the water
> Fal de ral de ral do*" (Lemon Jelly cit.)

![duck with sunglasses](duck_with_sunglasses.jpg)

# TODO
- [X] Travis
- [X] JSON renderer
- [ ] Tests! (some coverage, good enough for now ™, however if someone feels like to add more.. ;))
- [ ] Correct ASCII Art for the renderers that supports that (In progress)
- [ ] PNG Renderer with transparency (In progress)
- [ ] Integrate https://forecast.io as a backend?

# Thank yous

* The https://wttr.in project for inspiration
* ![wego](https://github.com/schachmat/wego) for the amazing ASCII art
