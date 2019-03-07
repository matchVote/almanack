defmodule Almanack.Sources.GoogleCivicInfoTest do
  use Almanack.TestCase
  alias Almanack.Sources.{GoogleCivicInfo, NGA}

  setup_all do
    data = Fixtures.load("gci_representatives.json")

    address = %NGA{
      line1: "1 Front Row",
      city: "Keats",
      state: "Hyperion",
      zip: "12345-6789"
    }

    {:ok, addresses: [address], data: data}
  end

  describe "officials/0" do
    test "returns list of Official changesets", %{data: data, addresses: adds} do
      mock(NGA, :governors_addresses, adds)
      mock(GoogleCivicInfo.API, :representatives, data)

      [bobeck | []] = GoogleCivicInfo.officials()
      assert bobeck.changes.first_name == "Bobeck"
      assert bobeck.changes.last_name == "Kuberdoodles"
    end
  end

  @tag :PropEr
  describe "normalize_address/1" do
    test "converts NGA address struct to string", %{addresses: [add | _]} do
      result = GoogleCivicInfo.normalize_address(add)
      assert result == "1 Front Row Keats Hyperion 12345-6789"
    end
  end
end
