defmodule Almanack.Sources.USIO do
  import Mockery.Macro
  alias __MODULE__.API
  alias Almanack.AddressParsing
  alias Almanack.Officials.{Enrichment, Official}

  @data_source "usio"

  @doc """
  Retrieves data on all current Congressional officials (House and Senate) from
  unitedstates.io and converts that data into Official changesets for further
  processing by the Almanack domain.
  """
  @spec officials() :: [Ecto.Changeset.t()]
  def officials do
    mockable(API).current_legislators()
    |> Enum.concat(mockable(API).executives())
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
          identifiers: standardize_ids(data["id"]),
          official_name: data["name"]["official_full"],
          first_name: data["name"]["first"],
          middle_name: data["name"]["middle"],
          last_name: data["name"]["last"],
          suffix: data["name"]["suffix"],
          nickname: data["name"]["nickname"],
          birthday: data["bio"]["birthday"],
          gender: Enrichment.standardize_gender(data["bio"]["gender"]),
          religion: data["bio"]["religion"],
          data_source: @data_source
        ),
        data
      }
    end)
  end

  defp standardize_ids(ids) do
    Enum.reduce(ids, %{}, fn {key, id}, acc ->
      Map.put(acc, Enrichment.standardize_media_key(key), id)
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
      {role, branch} = parse_role_and_branch(term["type"])

      %{
        start_date: term["start"],
        end_date: term["end"],
        role: role,
        party: Enrichment.standardize_party(term["party"]),
        state: term["state"],
        state_rank: term["state_rank"],
        contact_form: term["contact_form"],
        phone_number: term["phone"],
        fax_number: term["fax"],
        website: term["url"],
        address: AddressParsing.parse(term["address"]),
        level: "federal",
        branch: branch
      }
    end)
  end

  defp parse_role_and_branch(type) do
    case type do
      "sen" ->
        {"Senator", "legislative"}

      "rep" ->
        {"Representative", "legislative"}

      "prez" ->
        {"President", "executive"}

      "viceprez" ->
        {"Vice President", "executive"}

      nil ->
        {"", ""}

      _ ->
        {type, ""}
    end
  end

  defp include_social_media(officials) do
    social_media = mockable(API).social_media()

    Enum.map(officials, fn {official, _} = tuple ->
      media = find_official_media(social_media, official)

      official =
        Official.update_change(official, :identifiers, fn ids ->
          Map.merge(ids, Map.get(media, "social", %{}))
        end)

      :erlang.setelement(1, tuple, official)
    end)
  end

  defp find_official_media(media, official) do
    ids = Official.get_change(official, :identifiers)

    Enum.find(media, %{}, fn media_ids ->
      media_ids["id"]["bioguide"] == ids["bioguide"]
    end)
  end
end
