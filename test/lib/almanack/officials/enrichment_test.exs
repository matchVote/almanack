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
end
