defmodule Almanack.Sources.Ballotpedia do
  import Mockery.Macro
  require Logger
  alias __MODULE__.API
  alias Almanack.Officials.{Enrichment, Official}

  @mayors_table_class ".bptable"

  @spec officials() :: [Ecto.Changeset.t()]
  def officials do
    [_title, headers | mayors] =
      mockable(API).top_mayors_html()
      |> Floki.find(@mayors_table_class)
      |> Floki.find("tr")

    headers = cleanse_headers(headers)

    Enum.map(mayors, fn mayor ->
      data =
        Floki.find(mayor, "td")
        |> Enum.map(&String.trim(Floki.text(&1)))

      Enum.zip(headers, data)
      |> Map.new()
      |> determine_party()
      |> normalize_name()
      |> map_to_official()
    end)
  end

  defp cleanse_headers(headers) do
    headers
    |> Floki.find("th")
    |> Enum.map(fn value ->
      value
      |> Floki.text()
      |> String.trim()
      |> String.downcase()
    end)
  end

  @spec determine_party(map()) :: map()
  def determine_party(%{"mayor" => name} = data) do
    party =
      case Regex.run(~r/.+\((.)\)$/, name, capture: :all_but_first) do
        [symbol] -> Enrichment.standardize_party(symbol)
        nil -> nil
      end

    Map.put(data, "party", party)
  end

  @spec normalize_name(map()) :: map()
  def normalize_name(%{"mayor" => name, "party" => party} = data) do
    name =
      name
      |> remove_party(party)
      |> Enrichment.split_name()

    data
    |> Map.merge(%{
      "first_name" => name.first_name,
      "last_name" => name.last_name,
      "middle_name" => name.middle_name,
      "suffix" => name.suffix
    })
  end

  defp remove_party(name, nil), do: name

  defp remove_party(name, _) do
    String.slice(name, 0, String.length(name) - 3)
  end

  defp map_to_official(data) do
    Official.new(
      first_name: data["first_name"],
      middle_name: data["middle_name"],
      last_name: data["last_name"],
      suffix: data["suffix"],
      terms: [
        %{
          start_date: add_day_month(data["took office"]),
          end_date: add_day_month(data["term ends"]),
          state: extract_state(data["city"]),
          party: data["party"],
          role: "Mayor",
          level: "city"
        }
      ]
    )
  end

  defp add_day_month(year) do
    "#{year}-01-01"
  end

  @spec extract_state(String.t()) :: String.t()
  def extract_state(city) do
    [_ | [state]] = String.split(city, ", ")
    # TODO: This is not abbreviated
    state
  end

  defmodule API do
    @spec top_mayors_html() :: String.t()
    def top_mayors_html() do
      HTTPoison.get!(config(:top_mayors_url)).body
    end

    defp config(key) do
      Application.get_env(:almanack, :ballotpedia)[key]
    end
  end
end
