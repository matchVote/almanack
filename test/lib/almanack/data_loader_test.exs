defmodule Almanack.DataLoaderTest do
  use Almanack.RepoCase
  alias Almanack.DataLoader
  alias Almanack.Sources.USIO
  alias Almanack.Officials.Official

  setup_all do
    legislators = Fixtures.load("usio_legislators.json")
    media = Fixtures.load("usio_social_media.json")
    {:ok, legislators: legislators, media: media}
  end

  describe "run/1" do
    test "inserts new officials to DB", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)

      DataLoader.run()
      officials = Repo.all(Official)
      assert length(officials) == 3
      assert Enum.find(officials, &(&1.first_name == "Sherrod"))
      assert Enum.find(officials, &(&1.first_name == "Maria"))
    end

    test "updates existing officials in DB", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)

      %Official{bioguide_id: "B000944", first_name: "Clancy"}
      |> Repo.insert()

      DataLoader.run()
      official = Repo.get_by(Official, bioguide_id: "B000944")
      assert official.first_name == "Sherrod"
    end

    test "only modifies 'updated_at' and not 'created_at'", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)

      old_time =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.add(-1)
        |> NaiveDateTime.truncate(:second)

      old_official =
        %Official{bioguide_id: "B000944", created_at: old_time, updated_at: old_time}
        |> Repo.insert!()

      DataLoader.run()
      official = Repo.get_by(Official, bioguide_id: "B000944")
      assert old_official.created_at == official.created_at
      refute old_official.updated_at == official.updated_at
    end

    test "includes social media ids", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      DataLoader.run()
      official = Repo.get_by(Official, bioguide_id: "B000944")
      assert official.media["twitter_id"] == "43910797"
    end

    test "official slug is added", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      DataLoader.run()
      official = Repo.get_by(Official, bioguide_id: "B000944")
      assert official.slug == "sherrod-brown"
    end

    test "defaults are set", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      DataLoader.run()
      official = Repo.get_by(Official, bioguide_id: "B000944")
      assert official.branch == "legislative"
      assert official.status == "in_office"
    end

    test "formats gender values", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      DataLoader.run()
      sherrod = Repo.get_by(Official, bioguide_id: "B000944")
      assert sherrod.gender == "male"
      maria = Repo.get_by(Official, bioguide_id: "C000127")
      assert maria.gender == "female"
    end
  end
end
