defmodule Almanack.Officials.ProfilePicsTest do
  use Almanack.RepoCase
  alias Almanack.Officials.{Official, ProfilePics}

  describe "update_profile_pics/2" do
    setup do
      pic = %{
        url: "https://data.matchvote.com/images/2015/congress/Dunder_Mifflin.jpeg",
        first_name: "Dunder",
        last_name: "Mifflin",
        slug: "dunder-mifflin"
      }

      {:ok, pic: pic}
    end

    test "profile_pic is updated with a URL when official does not have one", %{pic: pic} do
      official =
        Official.new(first_name: "Dunder", last_name: "Mifflin", slug: "dunder-mifflin")
        |> Repo.insert!()

      ProfilePics.update_profile_pics([pic], [official])
      official = Repo.get_by!(Official, last_name: "Mifflin")
      assert official.profile_pic == pic.url
    end

    test "profile_pic is not updated if no pic is found for official", %{pic: pic} do
      official =
        Official.new(first_name: "D", last_name: "M", slug: "d-m")
        |> Repo.insert!()

      ProfilePics.update_profile_pics([pic], [official])
      official = Repo.get_by!(Official, last_name: "M")
      refute official.profile_pic
    end
  end

  describe "find_pic/2" do
    setup do
      pics = [
        %{url: "url1", first_name: "a", last_name: "b", slug: "a-b"},
        %{url: "url2", first_name: "c", last_name: "d", slug: "c-d"}
      ]

      {:ok, pics: pics}
    end

    test "returns pic based on official slug", %{pics: pics} do
      official = %Official{slug: "c-d"}
      pic = ProfilePics.find_pic(pics, official)
      assert pic.url == "url2"
    end
  end

  describe "parse_urls/1" do
    setup do
      urls = [
        "https://data.matchvote.com/images/2017/mayors/GT_Bynum.jpeg",
        "https://data.matchvote.com/images/2015/governors/Chris_Sununu.jpeg",
        "https://data.matchvote.com/images/2015/senators/Elizabeth_Warren.jpeg",
        "https://data.matchvote.com/images/2015/congress/Amata_Coleman_Radewagen.jpeg",
        "https://data.matchvote.com/images/2017/mayors/Paula_Hicks-Hudson.jpeg"
      ]

      {:ok, urls: urls}
    end

    test "url is passed", %{urls: urls} do
      pic_urls =
        ProfilePics.parse_urls(urls)
        |> Enum.map(&Map.get(&1, :url))

      assert pic_urls == urls
    end

    test "slug is generated", %{urls: urls} do
      slugs =
        ProfilePics.parse_urls(urls)
        |> Enum.map(&Map.get(&1, :slug))

      assert slugs == [
               "gt-bynum",
               "chris-sununu",
               "elizabeth-warren",
               "amata-radewagen",
               "paula-hicks-hudson"
             ]
    end
  end
end
