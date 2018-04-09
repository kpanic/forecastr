defmodule Forecastr.Renderer.PNG do
  @moduledoc """
  PNG renderer
  Render from a list of text to PNG

  Currently the PNG is generated only from the *current* weather forecast coming
  from the Forecastr.OWM module

  The PNG will be written to the file system based on the :image_path
  Application variable.
  """
  import Mogrify

  @doc """
  Render a map coming from the backend (OWM API currently) to a PNG
  Return the image name.
  """
  @spec render(map()) :: String.t()
  def render(map = %{"name" => city_name}) do
    map
    |> Forecastr.Renderer.ASCII.render()
    |> render_png(city_name)
  end

  @doc """
  Render a PNG from an ascii and a city name
  """
  @spec render_png(list(), String.t()) :: String.t()
  def render_png(ascii, city_name) when is_list(ascii) do
    city_name = String.downcase(city_name)

    filename = "#{city_name}.png"
    path = Application.fetch_env!(:forecastr, :image_path)

    %Mogrify.Image{path: filename, ext: "png"}
    |> custom("size", "280x280")
    |> canvas("black")
    |> custom("gravity", "center")
    |> custom("fill", "white")
    |> custom("font", "DejaVu-Sans-Mono-Bold")
    |> custom("draw", "text 0,0 '#{ascii}'")
    |> create(path: path)

    filename
  end
end
