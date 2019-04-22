defmodule Forecastr.Renderer.PNG do
  @moduledoc """
  PNG renderer
  Render from a list of text to PNG

  Currently the PNG is generated only from the *current* weather forecast coming
  from the Forecastr.OWM module

  The PNG will be written returned as binary buffer.
  """
  import Mogrify

  @doc """
  Render a map coming from the backend (OWM API currently)
  """
  @spec render(map()) :: map()
  def render(%{"name" => city_name} = map) do
    map
    |> Forecastr.Renderer.ASCII.render(:png)
    |> render_png(city_name)
  end

  @doc """
  Render a map with the binary of the PNG and the name of the city from an ascii
  and a city name
  """
  @spec render_png(list(), String.t()) :: map()
  def render_png(ascii, city_name) when is_list(ascii) do
    city_name = String.downcase(city_name)
    ascii = ["<tt>", ascii, "</tt>"]

    image =
      %Mogrify.Image{}
      |> custom("size", "280x280")
      |> custom("background", "#000000")
      |> custom("fill", "white")
      |> custom("font", "DejaVu-Sans-Mono-Bold")
      |> prepare_ascii_for_pango(ascii)
      |> custom("stdout", "png:-")
      |> create(buffer: true)

    %{name: city_name, binary: image.buffer}
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
