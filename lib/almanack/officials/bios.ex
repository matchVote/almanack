defmodule Almanack.Officials.Bios do
  import Ecto.Query
  import Mockery.Macro
  alias __MODULE__.Wikipedia
  alias Almanack.Repo
  alias Almanack.Officials.Official

  @default_bio "To Be Added"

  def load do
    officials_without_bios()
    |> Enum.map(fn official ->
      case official.identifiers["wikipedia"] do
        nil ->
          Official.changeset(official, %{bio: @default_bio})

        key ->
          bio =
            mockable(Wikipedia).request_bio(key)
            |> Wikipedia.extract_bio(@default_bio)

          Official.changeset(official, %{bio: bio})
      end
    end)
    |> Enum.each(fn cs ->
      Repo.update!(cs)
    end)
  end

  defp officials_without_bios do
    from(o in Official, where: is_nil(o.bio))
    |> Repo.all()
  end

  defmodule Wikipedia do
    def request_bio(key) do
    end

    def extract_bio(data, default_bio) do
      data["query"]["pages"]
      |> Map.values()
      |> List.first()
      |> Map.get("extract", default_bio)
    end
  end
end
