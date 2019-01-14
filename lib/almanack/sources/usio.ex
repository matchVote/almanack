defmodule Almanack.Sources.USIO do
  import Mockery.Macro
  alias __MODULE__.API
  alias Almanack.Official

  @spec legislators() :: [Ecto.Changeset.t()]
  def legislators do
    mockable(API).current_legislators()
    |> map_to_officials()
    |> format_gender()
  end

  defp map_to_officials(legislators) do
    Enum.map(legislators, fn legislator ->
      Official.new(
        bioguide_id: legislator["id"]["bioguide"],
        official_name: legislator["name"]["official_full"],
        first_name: legislator["name"]["first"],
        middle_name: legislator["name"]["middle"],
        last_name: legislator["name"]["last"],
        suffix: legislator["name"]["suffix"],
        nickname: legislator["name"]["nickname"],
        birthday: legislator["bio"]["birthday"],
        gender: legislator["bio"]["gender"],
        religion: legislator["bio"]["religion"],
        media: legislator["social_media"]
      )
    end)
  end

  defp format_gender(officials) do
    Enum.map(officials, fn official ->
      gender =
        Official.get_change(official, :gender)
        |> to_string()
        |> String.capitalize()
        |> expand_gender()

      Official.change(official, %{gender: gender})
    end)
  end

  defp expand_gender("M"), do: "male"
  defp expand_gender("F"), do: "female"
  defp expand_gender(_), do: nil

  def include_social_media(officials) do
    social_media = mockable(API).social_media()

    Enum.map(officials, fn official ->
      media = find_legislator_media(social_media, official)
      Official.changeset(official, %{media: Map.get(media, "social", %{})})
    end)
  end

  defp find_legislator_media(media, official) do
    Enum.find(media, %{}, fn media_ids ->
      media_ids["id"]["bioguide"] == official.changes.bioguide_id
    end)
  end
end
