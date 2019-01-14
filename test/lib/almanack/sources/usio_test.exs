defmodule Almanack.Sources.USIOTest do
  use Almanack.TestCase
  alias Almanack.Sources.USIO
  alias Almanack.Official

  setup_all do
    legislators = Fixtures.load("usio_legislators.json")
    media = Fixtures.load("usio_social_media.json")
    {:ok, legislators: legislators, media: media}
  end

  describe "legislators/0" do
    test "returns list of Official structs", context do
      mock(USIO.API, :current_legislators, context.legislators)
      [sherrod | [maria]] = Enum.slice(USIO.legislators(), 0, 2)
      %{last_name: last_name} = sherrod.changes
      assert last_name == "Brown"
      assert sherrod.changes.bioguide_id == "B000944"
      assert maria.changes.first_name == "Maria"
    end

    test "formats gender values", context do
      mock(USIO.API, :current_legislators, context.legislators)
      [sherrod | [maria]] = Enum.slice(USIO.legislators(), 0, 2)
      assert Official.get_change(sherrod, :gender) == "male"
      assert Official.get_change(maria, :gender) == "female"
    end
  end

  describe "include_social_media/1" do
    test "social media IDs are merged with legislators data", context do
      mock(USIO.API, :social_media, context.media)

      [sherrod | [maria]] =
        [
          Official.changeset(%Official{}, %{bioguide_id: "B000944"}),
          Official.changeset(%Official{}, %{bioguide_id: "C000127"})
        ]
        |> USIO.include_social_media()

      assert sherrod.changes.media["twitter"] == "SenSherrodBrownTest"
      assert maria.changes.media["facebook"] == "senatorcantwell_test"
    end

    test "social key is set to empty map if no social media is found", context do
      mock(USIO.API, :social_media, context.media)

      [fake | _] =
        [Official.changeset(%Official{}, %{bioguide_id: "UNKNOWN"})]
        |> USIO.include_social_media()

      assert fake.changes.media == %{}
    end
  end
end
