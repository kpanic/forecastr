defmodule Forecastr.OWM.HTTPTest do
  use ExUnit.Case

  test "process_url prepend http://" do
    assert "https://sorry-i-am-late.at" ==
             Forecastr.OWM.HTTP.process_request_url("sorry-i-am-late.at")
  end

  test "process_request_options returns more params" do
    Application.put_env(:forecastr, :appid, "test_appid")

    assert [params: %{APPID: "test_appid"}] ==
             Forecastr.OWM.HTTP.process_request_options(params: %{})
  end
end
