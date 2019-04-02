defmodule Almanack.Sources.StaticFiles do
  import Mockery.Macro
  alias Almanack.AddressParsing
  alias Almanack.Officials.{Enrichment, Official}

  @static_files_dir :code.priv_dir(:almanack) |> Path.join("data/static_files")

  @spec officials() :: [Ecto.Changeset.t()]
  def officials do
    mockable(__MODULE__).static_data()
    |> map_to_officials()
  end

  @spec static_data() :: [map]
  def static_data do
    @static_files_dir
    |> File.ls!()
    |> Enum.flat_map(fn file ->
      Path.join(@static_files_dir, file)
      |> YamlElixir.read_from_file!()
    end)
  end

  defp map_to_officials(raw_officials) do
    raw_officials
    |> Enum.map(fn data ->
      Official.new(
        identifiers: collect_ids(data),
        first_name: data["first_name"],
        last_name: data["last_name"],
        middle_name: data["middle_name"],
        nickname: data["nick_name"],
        suffix: data["suffix"],
        birthday: data["birthday"],
        gender: Enrichment.standardize_gender(data["gender"]),
        religion: data["religion"],
        sexual_orientation: data["orientation"],
        status: data["rep_status"],
        profile_pic: data["profile_pic"],
        name_recognition: data["name_recognition"],
        terms: [create_term(data)]
      )
    end)
  end

  defp collect_ids(data) do
    %{
      "facebook" => data["facebook"],
      "twitter" => data["twitter"],
      "wiki" => data["wiki"],
      "youtube" => data["youtube"]
    }
  end

  defp create_term(data) do
    %{
      start_date: Enrichment.standardize_date(data["took_office"]),
      end_date: Enrichment.standardize_date(data["term_ends"]),
      role: data["title"],
      state: data["state"],
      party: Enrichment.standardize_party(data["party"]),
      branch: data["branch"],
      level: data["branch"] && "federal",
      contact_form: data["contact_form_url"],
      phone_number: data["tel"],
      fax_number: data["fax"],
      website: data["web"],
      address: parse_address(data["address"])
    }
  end

  defp parse_address(address) do
    address
    |> remove_addressee()
    |> AddressParsing.parse()
  end

  defp remove_addressee(nil), do: nil

  defp remove_addressee(address) do
    cond do
      Regex.match?(~r/^(po box|\d)/, String.downcase(address)) ->
        address

      true ->
        [_ | parts] = String.split(address, ", ")
        Enum.join(parts, " ")
    end
  end
end
