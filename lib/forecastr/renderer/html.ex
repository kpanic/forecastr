defmodule Forecastr.Renderer.HTML do
  @moduledoc false

  @spec render(map()) :: list()
  def render(map) do
    map
    |> Forecastr.Renderer.ASCII.render()
    |> render_html()
  end

  # TODO: Use proper CSS/HTML
  defp render_html(ascii) when is_list(ascii) do
    [~S(<head>
      <meta charset="UTF-8">
      </head>), "<pre>", ascii, "</pre>"]
  end
end
