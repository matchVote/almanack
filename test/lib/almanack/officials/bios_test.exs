defmodule Almanack.Officials.BiosTest do
  use Almanack.RepoCase
  alias Almanack.Officials.{Bios, Official}

  setup do
    [
      %Official{mv_key: "arcus-post", identifiers: %{wikipedia: "Arcus Post"}},
      %Official{mv_key: "sonny"},
      %Official{mv_key: "hooboy", bio: "what?", identifiers: %{wikipedia: "Arcus Post"}},
      %Official{mv_key: "hamman-raptura", identifiers: %{wikipedia: "unknown"}}
    ]
    |> Enum.each(&Repo.insert!/1)

    {:ok, bios: Fixtures.load("wikipedia_bios.json")}
  end

  describe "load/0" do
    test "populates bio field with requested data from Wikipedia", %{bios: bios} do
      mock(Bios.Wikipedia, :request_bio, List.first(bios))
      Bios.load()
      official = Repo.get_by!(Official, mv_key: "arcus-post")
      assert official.bio == "My best friend is a penguin."
    end

    test "with no Wikipedia key, uses default bio value", %{bios: bios} do
      mock(Bios.Wikipedia, :request_bio, List.first(bios))
      Bios.load()
      official = Repo.get_by!(Official, mv_key: "sonny")
      assert official.bio == "To Be Added"
    end

    test "with no Wikipedia data, uses default bio value", %{bios: bios} do
      mock(Bios.Wikipedia, :request_bio, List.last(bios))
      Bios.load()
      official = Repo.get_by!(Official, mv_key: "hamman-raptura")
      assert official.bio == "To Be Added"
    end

    test "does nothing if official already has a bio", %{bios: bios} do
      mock(Bios.Wikipedia, :request_bio, List.first(bios))
      Bios.load()
      official = Repo.get_by!(Official, mv_key: "hooboy")
      assert official.bio == "what?"
    end
  end
end
