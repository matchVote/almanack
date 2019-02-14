defmodule Almanack.Sources.USIO do
  import Mockery.Macro
  alias __MODULE__.API
  alias Almanack.AddressParsing
  alias Almanack.Officials.Official

  @spec officials() :: [Ecto.Changeset.t()]
  def officials do
    mockable(API).current_legislators()
    |> map_to_officials()
    |> set_latest_term_values()
    |> include_social_media()
    |> Enum.map(fn {official, _} -> official end)
  end

  @spec map_to_officials([map]) :: [{Official.t(), map}]
  defp map_to_officials(legislators) do
    Enum.map(legislators, fn data ->
      {
        Official.new(
          bioguide_id: data["id"]["bioguide"],
          official_name: data["name"]["official_full"],
          first_name: data["name"]["first"],
          middle_name: data["name"]["middle"],
          last_name: data["name"]["last"],
          suffix: data["name"]["suffix"],
          nickname: data["name"]["nickname"],
          birthday: data["bio"]["birthday"],
          gender: data["bio"]["gender"],
          religion: data["bio"]["religion"],
          media: data["social_media"]
        ),
        data
      }
    end)
  end

  defp set_latest_term_values(officials) do
    Enum.map(officials, fn {official, data} = tuple ->
      terms = Map.get(data, "terms", [%{}])
      latest_term = List.last(terms)
      [first_term | _] = terms

      official =
        official
        |> Official.change(%{
          party: latest_term["party"],
          state: latest_term["state"],
          state_rank: latest_term["state_rank"],
          contact_form: latest_term["contact_form"],
          emails: [],
          phone_number: latest_term["phone"],
          website: latest_term["url"],
          address: AddressParsing.parse(latest_term["address"])
        })
        |> seniority_date(first_term["start"])
        |> government_role(latest_term["type"])

      :erlang.setelement(1, tuple, official)
    end)
  end

  defp seniority_date(official, nil), do: official

  defp seniority_date(official, date) do
    Official.change(official, %{seniority_date: Date.from_iso8601!(date)})
  end

  defp government_role(official, role) do
    role =
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

    Official.change(official, %{government_role: role})
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
      media_ids["id"]["bioguide"] == official.changes.bioguide_id
    end)
  end
end
