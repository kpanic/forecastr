defmodule Forecastr.Renderer.PNG do
  @moduledoc false
  import Mogrify

  @spec render(map()) :: String.t()
  def render(map = %{"name" => city_name}) do
    map
    |> Forecastr.Renderer.ASCII.render()
    |> render_png(city_name)
  end

  def render(map = %{"city" => %{"name" => city_name}}) do
    "#{city_name}.png"
  end

  defp render_png(ascii, city_name) when is_list(ascii) do
    city_name = String.downcase(city_name)

    filename = "#{city_name}.png"
    path = Application.fetch_env!(:forecastr, :image_path)

    %Mogrify.Image{path: filename, ext: "png"}
    |> custom("size", "280x280")
    |> canvas("black")
    |> custom("gravity", "center")
    |> custom("fill", "white")
    |> custom("font", "FreeMono-Bold")
    |> custom("draw", "text 0,0 '#{ascii}'")
    |> create(path: path)

    filename
  end
end
