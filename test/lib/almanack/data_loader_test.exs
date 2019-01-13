defmodule Almanack.DataLoaderTest do
  use Almanack.RepoCase
  alias Almanack.Sources.USIO
  alias Almanack.{DataLoader, Official}

  setup_all do
    legislators = Fixtures.load("usio_legislators.json")
    media = Fixtures.load("usio_social_media.json")
    {:ok, legislators: legislators, media: media}
  end

  @tag :integration
  describe "run/1" do
    test "inserts new officials to DB", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)

      DataLoader.run()
      officials = Repo.all(Official)
      assert length(officials) == 2
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
  end
end
