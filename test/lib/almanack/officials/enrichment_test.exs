defmodule Almanack.Officials.EnrichmentTest do
  use ExUnit.Case, async: true
  alias Almanack.Officials.{Enrichment, Official}

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
      official = Official.new(nickname: "J.R", last_name: "Dory")
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
      assert Enrichment.standardize_party("Republican Party") == "Republican"
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
