defmodule Almanack.Sources.USIOTest do
  use Almanack.TestCase
  alias Almanack.Sources.USIO
  alias Almanack.Officials.Official

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
      %{last_name: last_name} = sherrod.changes
      assert last_name == "Brown"
      assert sherrod.changes.bioguide_id == "B000944"
      assert maria.changes.first_name == "Maria"
    end

    test "collects official names", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | [maria]] = Enum.slice(USIO.officials(), 0, 2)
      assert sherrod.changes.official_name == "Sherrod Brown"
      assert maria.changes.official_name == "Maria Cantwell"
    end

    test "formats gender values", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | [maria]] = Enum.slice(USIO.officials(), 0, 2)
      assert Official.get_change(sherrod, :gender) == "male"
      assert Official.get_change(maria, :gender) == "female"
    end

    test "downcases religion values", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | [maria]] = Enum.slice(USIO.officials(), 0, 2)
      assert Official.get_change(sherrod, :religion) == "lutheran"
      assert Official.get_change(maria, :religion) == "roman catholic"
    end

    test "defaults are set", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | _] = USIO.officials()
      assert Official.get_change(sherrod, :status) == "in_office"
      assert Official.get_change(sherrod, :branch) == "legislative"
    end

    test "includes latest term values", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | _] = Enum.slice(USIO.officials(), 0, 2)
      {:ok, date} = Date.new(1993, 1, 5)
      assert Official.get_change(sherrod, :party) == "Democrat"
      assert Official.get_change(sherrod, :state) == "OH"
      assert Official.get_change(sherrod, :state_rank) == "senior"
      assert Official.get_change(sherrod, :seniority_date) == date
      assert Official.get_change(sherrod, :government_role) == "Senator"
      assert Official.get_change(sherrod, :contact_form) == "http://www.brown.senate.gov/contact/"
      assert Official.get_change(sherrod, :phone_number) == "202-224-2315"
      assert Official.get_change(sherrod, :emails) == []
      assert Official.get_change(sherrod, :website) == "https://www.brown.senate.gov"
    end

    test "parses office address", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | _] = Enum.slice(USIO.officials(), 0, 2)
      address = Official.get_change(sherrod, :address)
      assert address["line1"] == "713 Hart Senate Office Building"
      assert address["city"] == "Washington"
      assert address["state"] == "DC"
      assert address["zip"] == "20510"
    end

    test "social media IDs are added officials media", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      [sherrod | [maria]] = Enum.slice(USIO.officials(), 0, 2)
      assert sherrod.changes.media["twitter"] == "SenSherrodBrownTest"
      assert maria.changes.media["facebook"] == "senatorcantwell_test"
    end

    test "social key is set to empty map if no social media is found", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      fake = List.last(USIO.officials())
      assert fake.changes.media == %{}
    end
  end
end
