defmodule Almanack.OfficialTest do
  use Almanack.RepoCase
  alias Almanack.Official

  @data %{
    bioguide_id: "X",
    official_name: "Doobie",
    first_name: "Doobert",
    last_name: "Kilgore",
    middle_name: "Hugh",
    nickname: "Dilgore",
    suffix: "",
    birthday: NaiveDateTime.utc_now(),
    gender: "M",
    religion: "Atheist",
    media: %{"arb" => "itrary"},
    branch: "somebranch",
    status: "not_dead!",
    party: "Green",
    state: "OH",
    state_rank: "senior",
    seniority_date: NaiveDateTime.utc_now(),
    government_role: "Representative",
    contact_form: "somewhere.com/form",
    phone_number: "111-222-3334",
    emails: ["anything"],
    website: "what.io",
    address: %{
      "line1" => "123",
      "city" => "Texas",
      "state" => "WY",
      "zip" => "12345"
    }
  }

  test "all fields are accounted for" do
    official =
      Official.changeset(%Official{}, @data)
      |> Repo.insert!()

    assert official.branch == "somebranch"
    assert official.status == "not_dead!"
    assert official.media["arb"] == "itrary"
    assert official.government_role == "Representative"
    assert official.emails == ["anything"]
    assert official.address["line1"] == "123"
    assert official.address["city"] == "Texas"
    assert official.address["state"] == "WY"
    assert official.address["zip"] == "12345"
  end
end
