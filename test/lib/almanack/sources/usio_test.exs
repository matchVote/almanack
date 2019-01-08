defmodule Almanack.Sources.USIOTest do
  use ExUnit.Case
  import Mockery
  alias Almanack.Sources.USIO

  setup_all do
    with {:ok, json} <- File.read("test/fixtures/usio_legislators.json"),
         {:ok, legislators} <- Poison.decode(json) do
      {:ok, legislators: legislators}
    end
  end

  describe "data/0" do
    test "returns list of maps of legislator data", context do
      mock(USIO.API, :current_legislators, context.legislators)
      [sherrod | [maria]] = USIO.data()
      assert sherrod["id"]["bioguide"] == "B000944"
      assert maria["name"]["first"] == "Maria"
    end

    @tag :skip
    test "social media IDs are merged with legislators data" do
      data = USIO.data()
    end
  end
end
