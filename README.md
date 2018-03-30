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

![today](today.png)

Sample output for 5 days:


![in 5 days](in_five_days.png)

> "*All the ducks are swimming in the water
> Fal de ral de ral do*" (Lemon Jelly cit.)

![duck with sunglasses](duck_with_sunglasses.jpg)

# TODO
- [X] Travis
- [ ] Correct ASCII Art for the renderers that supports that (In progress)
- [ ] Tests!
- [ ] Integrate https://forecast.io as a backend?
- [ ] HTML renderer
- [ ] JSON renderer
- [ ] PNG Renderer (with transparency)

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

