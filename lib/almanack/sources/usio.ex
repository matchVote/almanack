defmodule Almanack.Sources.USIO do
  import Mockery.Macro
  alias __MODULE__.API
  alias Almanack.Official

  @spec legislators() :: [Ecto.Changeset.t()]
  def legislators do
    mockable(API).current_legislators()
    |> map_to_officials()
    |> set_defaults()
    |> format_gender()
    |> downcase_religion()
    |> set_latest_term_values()
    |> return_changes()
  end

  @spec map_to_officials([map]) :: [{Official.t(), map}]
  defp map_to_officials(legislators) do
    Enum.map(legislators, fn legislator ->
      {
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
        ),
        legislator
      }
    end)
  end

  defp set_defaults(officials) do
    Enum.map(officials, fn {official, _} = data ->
      official =
        Official.change(
          official,
          branch: "legislative",
          status: "in_office"
        )

      :erlang.setelement(1, data, official)
    end)
  end

  defp format_gender(officials) do
    Enum.map(officials, fn {official, _} = data ->
      gender =
        Official.get_change(official, :gender)
        |> to_string()
        |> String.capitalize()
        |> expand_gender()

      :erlang.setelement(1, data, Official.change(official, %{gender: gender}))
    end)
  end

  defp expand_gender("M"), do: "male"
  defp expand_gender("F"), do: "female"
  defp expand_gender(_), do: nil

  defp downcase_religion(officials) do
    Enum.map(officials, fn {official, _} = data ->
      religion =
        Official.get_change(official, :religion, "")
        |> String.downcase()

      :erlang.setelement(1, data, Official.change(official, %{religion: religion}))
    end)
  end

  defp set_latest_term_values(officials) do
    Enum.map(officials, fn {official, legislator} = data ->
      terms = Map.get(legislator, "terms", [%{}])
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
          website: latest_term["url"]
        })
        |> seniority_date(first_term["start"])
        |> government_role(latest_term["type"])

      :erlang.setelement(1, data, official)
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

  defp return_changes(officials) do
    Enum.map(officials, fn {official, _} -> official end)
  end

  def include_social_media(officials) do
    social_media = mockable(API).social_media()

    Enum.map(officials, fn official ->
      media = find_official_media(social_media, official)
      Official.changeset(official, %{media: Map.get(media, "social", %{})})
    end)
  end

  defp find_official_media(media, official) do
    Enum.find(media, %{}, fn media_ids ->
      media_ids["id"]["bioguide"] == official.changes.bioguide_id
    end)
  end
end
