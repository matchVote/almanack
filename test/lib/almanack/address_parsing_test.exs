defmodule Almanack.AddressParsingTest do
  use ExUnit.Case, async: true
  alias Almanack.AddressParsing

  describe "parse/1" do
    test "converts an address string into a map" do
      address = "123 Hey Pockey Way Doobie NC 12345"
      result = AddressParsing.parse(address)
      assert result["line1"] == "123 Hey Pockey Way"
      assert result["city"] == "Doobie"
      assert result["state"] == "NC"
      assert result["zip"] == "12345"
    end

    test "returns map with empty string values if address is nil" do
      AddressParsing.parse(nil)
      |> Enum.each(fn {_, v} -> assert v == "" end)
    end
  end
end
