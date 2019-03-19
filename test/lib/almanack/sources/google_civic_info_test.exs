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

    test "includes standardized identifiers", %{data: data, addresses: adds} do
      mock(NGA, :governors_addresses, adds)
      mock(GoogleCivicInfo.API, :representatives, data)

      [bobeck | []] = GoogleCivicInfo.officials()
      assert bobeck.changes.identifiers["twitter"] == "NC_Governor"
    end

    test "includes terms", %{data: data, addresses: adds} do
      mock(NGA, :governors_addresses, adds)
      mock(GoogleCivicInfo.API, :representatives, data)

      [bobeck | []] = GoogleCivicInfo.officials()
      latest_term = List.last(bobeck.changes.terms)
      refute Map.has_key?(latest_term.changes, :start_date)
      assert latest_term.changes.party == "Democrat"
      assert latest_term.changes.state == "NC"
      assert latest_term.changes.role == "Governor"
      assert latest_term.changes.phone_number == "(920) 815-1999"
      assert latest_term.changes.emails == ["bobeck.kb@nc.gov"]
      assert latest_term.changes.website == "https://governor.nc.gov/"
      assert latest_term.changes.level == "state"
    end

    test "parses office addresses for terms", %{data: data, addresses: adds} do
      mock(NGA, :governors_addresses, adds)
      mock(GoogleCivicInfo.API, :representatives, data)

      [bobeck | []] = GoogleCivicInfo.officials()
      latest_term = List.last(bobeck.changes.terms)
      assert latest_term.changes.address["line1"] == "20301 Mail Service Center"
      assert latest_term.changes.address["city"] == "Raleigh"
      assert latest_term.changes.address["state"] == "NC"
      assert latest_term.changes.address["zip"] == "27699"
    end
  end

  @tag :PropEr
  describe "normalize_address/1" do
    test "converts NGA address struct to string", %{addresses: [add | _]} do
      result = GoogleCivicInfo.normalize_address(add)
      assert result == "1 Front Row Keats Hyperion 12345-6789"
    end
  end

  @tag :PropEr
  describe "split_name/1" do
    test "extracts first and last name" do
      result = GoogleCivicInfo.split_name("Franz Ferdinand")
      assert "Franz" == result.first_name
      assert "Ferdinand" == result.last_name
      assert "" == result.middle_name
    end

    test "extracts middle name" do
      result = GoogleCivicInfo.split_name("Franz P. Ferdinand")
      assert "Franz" == result.first_name
      assert "Ferdinand" == result.last_name
      assert "P." == result.middle_name
    end

    test "extracts suffix with middle name" do
      result = GoogleCivicInfo.split_name("Franz P. Ferdinand Jr.")
      assert "Franz" == result.first_name
      assert "P." == result.middle_name
      assert "Ferdinand" == result.last_name
      assert "Jr." == result.suffix
    end

    @tag skip: "split_name/1 will have to be made more robust"
    test "extracts suffix with no middle name" do
      result = GoogleCivicInfo.split_name("Franz Ferdinand Jr.")
      assert "Franz" == result.first_name
      assert "" == result.middle_name
      assert "Ferdinand" == result.last_name
      assert "Jr." == result.suffix
    end
  end

  @tag :PropEr
  describe "standardize_ids/1" do
    test "channels data is converted to map of ids with standard keys" do
      ids = [%{"type" => "Twitter", "id" => "MyName"}]
      result = GoogleCivicInfo.standardize_ids(ids)
      assert is_map(result)
      assert result["twitter"] == "MyName"
    end
  end
end
