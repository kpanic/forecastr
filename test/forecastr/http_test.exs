defmodule Forecastr.HTTPTest do
  use ExUnit.Case

  test "process_url prepend http://" do
    assert "http://sorry-i-am-late.at" == Forecastr.HTTP.process_url("sorry-i-am-late.at")
  end

  test "process_request_options returns more params" do
    Application.put_env(:forecastr, :appid, "test_appid")
    assert [params: %{APPID: "test_appid"}] == Forecastr.HTTP.process_request_options(params: %{})
  end
end
