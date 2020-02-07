defmodule Almanack.Sources.BallotpediaTest do
  use Almanack.TestCase
  alias Almanack.Sources.Ballotpedia

  describe "determine_party/1" do
    test "extracts party value from name and adds to data" do
      data =
        %{"mayor" => "London Breed (I)"}
        |> Ballotpedia.determine_party()

      assert data["party"] == "Independent"
    end

    test "sets party to nil if none can be extracted" do
      data =
        %{"mayor" => "London Breed"}
        |> Ballotpedia.determine_party()

      assert data["party"] == nil
    end

    test "captures nonpartisan" do
      data =
        %{"mayor" => "London Breed (Nonpartisan)"}
        |> Ballotpedia.determine_party()

      assert data["party"] == "Nonpartisan"
    end
  end

  describe "normalize_name/1" do
    test "name parts are extracted and added to data" do
      data =
        %{"mayor" => "Alan P. Krasnoff (R)", "party" => true}
        |> Ballotpedia.normalize_name()

      assert data["first_name"] == "Alan"
      assert data["last_name"] == "Krasnoff"
      assert data["middle_name"] == "P."
    end

    test "party is removed properly when more than one character" do
      data =
        %{"mayor" => "Alan Krasnoff (Nonpartisan)", "party" => true}
        |> Ballotpedia.normalize_name()

      assert data["first_name"] == "Alan"
      assert data["last_name"] == "Krasnoff"
      assert data["middle_name"] == ""
    end

    test "name parts without party are extracted and added to data" do
      data =
        %{"mayor" => "Alan Krasnoff", "party" => nil}
        |> Ballotpedia.normalize_name()

      assert data["first_name"] == "Alan"
      assert data["last_name"] == "Krasnoff"
      assert data["middle_name"] == ""
    end
  end

  describe "extract_state/1" do
    test "trims surrounding whitespace" do
      assert Ballotpedia.extract_state("New York, New York") == "New York"
    end
  end
end
