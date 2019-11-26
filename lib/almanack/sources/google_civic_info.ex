defmodule Almanack.Sources.GoogleCivicInfo do
  import Mockery.Macro
  require Logger
  alias __MODULE__.API
  alias Almanack.Sources.NGA
  alias Almanack.Officials.{Enrichment, Official}

  @spec officials() :: [Ecto.Changeset.t()]
  def officials do
    mockable(NGA).governors_addresses()
    |> Enum.map(fn address ->
      normalize_address(address)
      |> mockable(API).representatives()
      |> extract_governor()
      |> map_to_official()
      |> include_terms()
    end)
    |> Enum.reject(&is_nil/1)
  end

  @spec normalize_address(%NGA{}) :: String.t()
  def normalize_address(address) do
    "#{address.line1} #{address.city} #{address.state} #{address.zip}"
  end

  defp extract_governor(nil), do: nil

  defp extract_governor(data) do
    governor_index =
      data["offices"]
      |> Enum.find(&Regex.match?(~r/^Governor/, &1["name"]))
      |> Map.get("officialIndices")
      |> List.first()

    Enum.at(data["officials"], governor_index)
    |> Map.put("role", "Governor")
  end

  defp map_to_official(nil), do: nil

  defp map_to_official(data) do
    name_parts = Enrichment.split_name(data["name"])

    {Official.new(
       official_name: data["name"],
       first_name: name_parts.first_name,
       middle_name: name_parts.middle_name,
       last_name: name_parts.last_name,
       identifiers: standardize_ids(data["channels"])
     ), data}
  end

  def standardize_ids(nil), do: %{}

  @spec standardize_ids([map]) :: map
  def standardize_ids(ids) do
    Enum.reduce(ids, %{}, fn id, acc ->
      Map.put(acc, Enrichment.standardize_media_key(id["type"]), id["id"])
    end)
  end

  defp include_terms(nil), do: nil

  defp include_terms({official, data}) do
    Official.changeset(official, %{terms: map_terms(data)})
  end

  defp map_terms(data) do
    [address | _] = data["address"] || [%{}]

    [
      %{
        party: Enrichment.standardize_party(data["party"]),
        state: address["state"],
        role: data["role"],
        phone_number: List.first(data["phones"] || []),
        emails: data["emails"],
        website: List.first(data["urls"] || []),
        address: address,
        level: "state"
      }
    ]
  end

  defmodule API do
    @spec representatives(String.t()) :: map | nil
    def representatives(address) do
      case request(config(:representatives), address) do
        %{"error" => %{"message" => msg}} ->
          Logger.info("GoogleCivicInfo request error for '#{address}' -- #{msg}")
          nil

        reps ->
          reps
      end
    end

    defp request(resource, address) do
      {:ok, response} =
        %HTTPoison.Request{
          url: config(:base_url) <> resource,
          params: %{
            key: System.get_env("GOOGLE_CIVIC_INFO_API_KEY"),
            address: address
          }
        }
        |> HTTPoison.request()

      Jason.decode!(response.body)
    end

    defp config(key) do
      Application.get_env(:almanack, :gci_api)[key]
    end
  end
end
