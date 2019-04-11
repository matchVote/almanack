defmodule Almanack.Officials.BiosTest do
  use Almanack.RepoCase
  alias Almanack.Officials.{Bios, Official}

  setup do
    officials = %{
      arcus: %Official{mv_key: "arcus-post", identifiers: %{"wikipedia" => "Arcus Post"}},
      sonny: %Official{mv_key: "sonny"},
      hooboy: %Official{
        mv_key: "hooboy",
        bio: "what?",
        identifiers: %{"wikipedia" => "Arcus Post"}
      },
      hamman: %Official{mv_key: "hamman-raptura", identifiers: %{"wikipedia" => "unknown"}}
    }

    officials
    |> Map.values()
    |> Enum.each(fn official -> Repo.insert!(official) end)

    {:ok, bios: Fixtures.load("wikipedia_bios.json"), officials: officials}
  end

  test "officials_without_bios returns officials where :bio is nil" do
    officials = Bios.officials_without_bios()
    assert length(officials) == 3
    refute Enum.find(officials, &(&1.mv_key == "hooboy"))
  end

  describe "generate_bio/1" do
    test "populates bio field with requested data from Wikipedia", %{
      bios: [bio | _],
      officials: officials
    } do
      mock(Bios.Wikipedia, :request_bio, bio)
      changeset = Bios.generate_bio(officials.arcus)
      assert changeset.changes.bio == "My best friend is a penguin."
    end

    test "with no Wikipedia key, uses default bio value", %{bios: bios, officials: officials} do
      mock(Bios.Wikipedia, :request_bio, List.first(bios))
      changeset = Bios.generate_bio(officials.sonny)
      assert changeset.changes.bio == "To Be Added"
    end

    test "with no Wikipedia data, uses default bio value", %{bios: bios, officials: officials} do
      mock(Bios.Wikipedia, :request_bio, List.last(bios))
      changeset = Bios.generate_bio(officials.hamman)
      assert changeset.changes.bio == "To Be Added"
    end
  end
end
