defmodule Forecastr.Renderer.HTML do
  def render(map) do
    map
    |> Forecastr.Renderer.ASCII.render([return: :buffer])
    |> render_html()
  end

  defp render_html(ascii) when is_list(ascii) do
    ["<pre>", ascii, "</pre>"]
    |> IO.write()
  end
end
