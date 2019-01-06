defmodule AlmanackTest do
  use ExUnit.Case
  doctest Almanack

  test "greets the world" do
    assert Almanack.hello() == :world
  end
end
