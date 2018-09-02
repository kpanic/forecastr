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
    |> Forecastr.Renderer.ASCII.render(:png)
    |> render_png(city_name)
  end

  @doc """
  Render a PNG from an ascii and a city name
  """
  @spec render_png(list(), String.t()) :: String.t()
  def render_png(ascii, city_name) when is_list(ascii) do
    city_name = String.downcase(city_name)
    ascii = ["<tt>", ascii, "</tt>"]

    filename = "#{city_name}.png"
    path = Application.fetch_env!(:forecastr, :image_path)

    %Mogrify.Image{path: filename, ext: "png"}
    |> custom("size", "280x280")
    |> custom("background", "#000000")
    |> custom("fill", "white")
    |> custom("font", "DejaVu-Sans-Mono-Bold")
    |> prepare_ascii_for_pango(ascii)
    |> create(path: path)

    filename
  end

  defp prepare_ascii_for_pango(image, ascii) do
    ascii =
      Enum.map(List.flatten(ascii), fn element ->
        String.replace(element, "\\", "\\\\")
      end)

    image
    |> custom("pango", "#{ascii}")
  end
end
