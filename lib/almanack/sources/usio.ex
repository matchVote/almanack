defmodule Almanack.Sources.USIO do
  import Mockery.Macro
  alias __MODULE__.API

  def legislators do
    mockable(API).current_legislators()
    |> include_social_media()
    |> map_to_officials()
  end

  defp include_social_media(legislators) do
    social_media = mockable(API).social_media()

    Enum.map(legislators, fn legislator ->
      media = find_legislator_media(social_media, legislator)
      Map.put(legislator, "social_media", Map.get(media, "social", %{}))
    end)
  end

  defp map_to_officials(legislators) do
    Enum.map(legislators, fn legislator ->
      %Almanack.Official{
        bioguide_id: legislator["id"]["bioguide"],
        official_name: legislator["name"]["official_full"],
        first_name: legislator["name"]["first"],
        last_name: legislator["name"]["last"],
        media: legislator["social_media"]
      }
    end)
  end

  defp find_legislator_media(media, legislator) do
    Enum.find(media, %{}, fn media_ids ->
      media_ids["id"]["bioguide"] == legislator["id"]["bioguide"]
    end)
  end

  defmodule API do
    def current_legislators do
      request(config(:legislators))
    end

    def social_media do
      request(config(:social_media))
    end

    defp request(resource) do
      response = HTTPoison.get!(config(:base_url) <> resource)
      Poison.decode!(response.body)
    end

    defp config(key) do
      Application.get_env(:almanack, :usio_api)[key]
    end
  end
end
