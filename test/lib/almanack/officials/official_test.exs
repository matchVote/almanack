defmodule Almanack.Officials.OfficialTest do
  use Almanack.RepoCase
  alias Almanack.Officials.Official

  @data %{
    mv_key: "doobert-hugh-kilgore",
    identifiers: %{
      "bioguide_id" => "X",
      "twitter" => "DoobieTweets"
    },
    official_name: "Doobie",
    first_name: "Doobert",
    last_name: "Kilgore",
    middle_name: "Hugh",
    nickname: "Dilgore",
    suffix: "",
    birthday: NaiveDateTime.utc_now(),
    gender: "M",
    religion: "Atheist",
    sexual_orientation: "Heterosexual",
    status: "not_dead!",
    slug: "dilgore-kilgore"
  }

  test "all fields are accounted for" do
    official =
      Official.changeset(%Official{}, @data)
      |> Repo.insert!()

    assert official.mv_key == "doobert-hugh-kilgore"
    assert official.identifiers["bioguide_id"] == "X"
    assert official.official_name == "Doobie"
    assert official.first_name == "Doobert"
    assert official.last_name == "Kilgore"
    assert official.middle_name == "Hugh"
    assert official.nickname == "Dilgore"
    assert official.suffix == nil
    assert official.birthday != nil
    assert official.gender == "M"
    assert official.religion == "Atheist"
    assert official.sexual_orientation == "Heterosexual"
    assert official.status == "not_dead!"
    assert official.slug == "dilgore-kilgore"
  end

  test "new/1 includes mv_key" do
    result = Official.new(first_name: "Bo", last_name: "Berry", suffix: "Sr.")
    assert result.changes.mv_key == "bo-berry-sr"
  end

  test "changeset/2 casts terms" do
    official =
      Official.new(first_name: "Bo", last_name: "Berry")
      |> Official.changeset(%{
        terms: [
          %{
            "role" => "Senator",
            "level" => "federal",
            "address" => %{
              "line1" => "123 Way",
              "city" => "Seattle",
              "state" => "WA"
            }
          },
          %{
            "start_date" => "1993-01-04",
            "emails" => ["some@one.com"]
          }
        ]
      })

    [first | [second]] = official.changes.terms
    assert first.changes.role == "Senator"
    assert first.changes.address["city"] == "Seattle"
    {:ok, date} = Date.new(1993, 01, 04)
    assert second.changes.start_date == date
    assert second.changes.emails == ["some@one.com"]
  end
end
