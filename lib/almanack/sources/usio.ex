defmodule Almanack.Sources.USIO do
  import Mockery.Macro
  alias __MODULE__.API

  def data do
    mockable(API).current_legislators()
    |> include_social_media()
  end

  defp include_social_media(legislators) do
    Enum.map(legislators, fn legislator ->
      media = find_legislator_media(legislator)

      Map.put(legislator, "social", Map.get(media, "social", %{}))
    end)
  end

  defp find_legislator_media(legislator) do
    mockable(API).social_media()
    |> Enum.find(%{}, fn media ->
      media["id"]["bioguide"] == legislator["id"]["bioguide"]
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
