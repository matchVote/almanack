defmodule Almanack.Sources.USIOTest do
  use Almanack.TestCase
  alias Almanack.Sources.USIO

  setup_all do
    legislators = Fixtures.load("usio_legislators.json")
    media = Fixtures.load("usio_social_media.json")
    {:ok, legislators: legislators, media: media}
  end

  describe "officials/0" do
    test "returns list of Official structs", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | [maria]] = Enum.slice(USIO.officials(), 0, 2)
      assert sherrod.changes.last_name == "Brown"
      assert sherrod.changes.mv_key == "sherrod-brown"
      assert maria.changes.first_name == "Maria"
    end

    test "collects official names", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | [maria]] = Enum.slice(USIO.officials(), 0, 2)
      assert sherrod.changes.official_name == "Sherrod Brown"
      assert maria.changes.official_name == "Maria Cantwell"
    end

    test "includes terms", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | _] = Enum.slice(USIO.officials(), 0, 2)
      {:ok, start_date} = Date.new(2019, 1, 3)
      {:ok, end_date} = Date.new(2025, 1, 3)
      latest_term = List.last(sherrod.changes.terms)
      assert latest_term.changes.start_date == start_date
      assert latest_term.changes.end_date == end_date
      assert latest_term.changes.party == "Democrat"
      assert latest_term.changes.state == "OH"
      assert latest_term.changes.state_rank == "senior"
      assert latest_term.changes.role == "Senator"
      assert latest_term.changes.contact_form == "http://www.brown.senate.gov/contact/"
      assert latest_term.changes.phone_number == "202-224-2315"
      assert latest_term.changes.website == "https://www.brown.senate.gov"
    end

    test "parses office addresses for terms", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | _] = Enum.slice(USIO.officials(), 0, 2)
      latest_term = List.last(sherrod.changes.terms)
      assert latest_term.changes.address["line1"] == "713 Hart Senate Office Building"
      assert latest_term.changes.address["city"] == "Washington"
      assert latest_term.changes.address["state"] == "DC"
      assert latest_term.changes.address["zip"] == "20510"
    end

    test "social media IDs are added to identifiers map", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | [maria]] = Enum.slice(USIO.officials(), 0, 2)
      assert sherrod.changes.identifiers["twitter"] == "SenSherrodBrownTest"
      assert maria.changes.identifiers["facebook"] == "senatorcantwell_test"
    end
  end
end
