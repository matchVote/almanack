defmodule Almanack.Sources.USIO do
  import Mockery.Macro
  alias __MODULE__.API
  alias Almanack.AddressParsing
  alias Almanack.Officials.Official

  @spec officials() :: [Ecto.Changeset.t()]
  def officials do
    mockable(API).current_legislators()
    |> map_to_officials()
    |> include_terms()
    |> include_social_media()
    |> Enum.map(fn {official, _} -> official end)
  end

  @spec map_to_officials([map]) :: [{Official.t(), map}]
  defp map_to_officials(legislators) do
    Enum.map(legislators, fn data ->
      {
        Official.new(
          identifiers: data["id"],
          official_name: data["name"]["official_full"],
          first_name: data["name"]["first"],
          middle_name: data["name"]["middle"],
          last_name: data["name"]["last"],
          suffix: data["name"]["suffix"],
          nickname: data["name"]["nickname"],
          birthday: data["bio"]["birthday"],
          gender: data["bio"]["gender"],
          religion: data["bio"]["religion"]
        ),
        data
      }
    end)
  end

  defp include_terms(officials) do
    Enum.map(officials, fn {official, data} = tuple ->
      terms = cleanse_terms(data["terms"])
      official = Official.changeset(official, %{terms: terms})
      :erlang.setelement(1, tuple, official)
    end)
  end

  defp cleanse_terms(nil), do: [%{}]

  defp cleanse_terms(terms) do
    terms
    |> Enum.map(fn term ->
      %{
        start_date: term["start"],
        end_date: term["end"],
        role: government_role(term["type"]),
        party: term["party"],
        state: term["state"],
        state_rank: term["state_rank"],
        contact_form: term["contact_form"],
        phone_number: term["phone"],
        fax_number: term["fax"],
        website: term["url"],
        address: AddressParsing.parse(term["address"]),
        level: "federal",
        branch: "legislative"
      }
    end)
  end

  defp government_role(role) do
    case role do
      "sen" ->
        "Senator"

      "rep" ->
        "Representative"

      nil ->
        ""

      _ ->
        role
    end
  end

  defp seniority_date(official, nil), do: official

  defp seniority_date(official, date) do
    Official.change(official, %{seniority_date: Date.from_iso8601!(date)})
  end

  defp include_social_media(officials) do
    social_media = mockable(API).social_media()

    Enum.map(officials, fn {official, _} = tuple ->
      media = find_official_media(social_media, official)
      official = Official.changeset(official, %{media: Map.get(media, "social", %{})})
      :erlang.setelement(1, tuple, official)
    end)
  end

  defp find_official_media(media, official) do
    Enum.find(media, %{}, fn media_ids ->
      media_ids["id"]["bioguide"] == official.changes.identifiers["bioguide_id"]
    end)
  end
end
