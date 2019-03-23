defmodule Almanack.Officials.EnrichmentTest do
  use ExUnit.Case, async: true
  alias Almanack.Officials.{Enrichment, Official}

  @tag :PropEr
  describe "split_name/1" do
    test "extracts first and last name" do
      result = Enrichment.split_name("Franz Ferdinand")
      assert "Franz" == result.first_name
      assert "" == result.middle_name
      assert "Ferdinand" == result.last_name
      assert "" == result.suffix
    end

    test "extracts middle name" do
      result = Enrichment.split_name("Franz P. Ferdinand")
      assert "Franz" == result.first_name
      assert "P." == result.middle_name
      assert "Ferdinand" == result.last_name
      assert "" == result.suffix
    end

    test "extracts suffix with middle name" do
      result = Enrichment.split_name("Franz P. Ferdinand Jr.")
      assert "Franz" == result.first_name
      assert "P." == result.middle_name
      assert "Ferdinand" == result.last_name
      assert "Jr." == result.suffix
    end

    test "extracts suffix with no middle name" do
      result = Enrichment.split_name("Franz Ferdinand Jr.")
      assert "Franz" == result.first_name
      assert "" == result.middle_name
      assert "Ferdinand" == result.last_name
      assert "Jr." == result.suffix
    end
  end

  describe "generate_slug/1" do
    test "adds a readable composite name field to an official" do
      official = Official.new(first_name: "Bob", last_name: "Dory")
      result = Enrichment.generate_slug(official)
      assert result.changes.slug == "bob-dory"
    end

    test "prefers nickname over first name" do
      official = Official.new(nickname: "Doby", first_name: "Bob", last_name: "Dory")
      result = Enrichment.generate_slug(official)
      assert result.changes.slug == "doby-dory"
    end

    test "removes dots" do
      official = Official.new(nickname: "J.R.", last_name: "Dory")
      result = Enrichment.generate_slug(official)
      assert result.changes.slug == "jr-dory"
    end
  end

  describe "generate_mv_key/1" do
    setup do
      {:ok, %{fields: [:first_name, :middle_name, :last_name, :suffix]}}
    end

    test "creates unique official identifier", %{fields: fields} do
      key =
        %{
          first_name: "Bob",
          middle_name: "Humphrey",
          last_name: "Jones",
          suffix: "Jr."
        }
        |> Enrichment.generate_mv_key(fields)

      assert key == "bob-humphrey-jones-jr"
    end

    test "middle_name is optional", %{fields: fields} do
      key =
        %{
          first_name: "Bob",
          middle_name: nil,
          last_name: "Jones",
          suffix: "Jr."
        }
        |> Enrichment.generate_mv_key(fields)

      assert key == "bob-jones-jr"
    end

    test "suffix is optional", %{fields: fields} do
      key =
        %{
          first_name: "Bob",
          middle_name: nil,
          last_name: "Jones",
          suffix: nil
        }
        |> Enrichment.generate_mv_key(fields)

      assert key == "bob-jones"
    end
  end

  @tag :PropEr
  describe "standardize_party/1" do
    test "converts known variations into standard enum values" do
      assert Enrichment.standardize_party("Democratic Party") == "Democrat"
      assert Enrichment.standardize_party("Democrat") == "Democrat"
      assert Enrichment.standardize_party("D") == "Democrat"

      assert Enrichment.standardize_party("Republican Party") == "Republican"
      assert Enrichment.standardize_party("Republican") == "Republican"
      assert Enrichment.standardize_party("R") == "Republican"

      assert Enrichment.standardize_party("I") == "Independent"
    end

    test "does not modify unknown values" do
      assert Enrichment.standardize_party("Frat Party") == "Frat Party"
    end
  end

  @tag :PropEr
  describe "standardize_media_key/1" do
    test "downcases key" do
      assert Enrichment.standardize_media_key("Twitter") == "twitter"
    end
  end
end
