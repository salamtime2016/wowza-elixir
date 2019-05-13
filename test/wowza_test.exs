defmodule WowzaTest do
  use ExUnit.Case
  doctest Wowza

  test "greets the world" do
    assert Wowza.hello() == :world
  end
end
