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

  defp test_data do
    [sherrod | [maria]] = Enum.slice(USIO.data(), 0, 2)
    {sherrod, maria}
  end

  describe "data/0" do
    test "returns list of maps of legislator data", context do
      mock(USIO.API, :current_legislators, context.legislators)
      {sherrod, maria} = test_data()
      assert sherrod["id"]["bioguide"] == "B000944"
      assert maria["name"]["first"] == "Maria"
    end

    test "social media IDs are merged with legislators data", context do
      mock(USIO.API, :current_legislators, context.legislators)
      {sherrod, maria} = test_data()
      assert sherrod["social"]["twitter"] == "SenSherrodBrown"
      assert maria["social"]["facebook"] == "senatorcantwell"
    end

    test "social key is set to empty map if no social media is found", context do
      mock(USIO.API, :current_legislators, context.legislators)
      fake = List.last(USIO.data())
      assert fake["social"] == %{}
    end
  end
end
