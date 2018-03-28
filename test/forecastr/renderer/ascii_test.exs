defmodule ASCIITest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Forecastr.Renderer.ASCII


  test "errors are rendered" do
  assert capture_io(fn -> render({:error, :test_errrror}) end) == "Unable to prepare the weather report\nError: test_errrror\n"
  end
end
