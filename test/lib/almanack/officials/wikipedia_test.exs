defmodule Almanack.Officials.Bios.WikipediaTest do
  use ExUnit.Case, async: true
  alias Almanack.Officials.Bios.Wikipedia

  @doc """
  This tests the external Wikipedia API.
  """
  describe "request_bio/0" do
    test "with existing page, it returns expected JSON structure" do
      json = Wikipedia.request_bio("Amy Klobuchar")
      assert json["query"]["pages"]["1596343"]["extract"]
    end

    test "when page is not found, it returns expected JSON structure" do
      json = Wikipedia.request_bio("KLDOSasl")
      assert json["query"]["pages"]["-1"]["missing"]
    end
  end
end
