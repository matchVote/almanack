defmodule Almanack.Sources.USIO.API do
  def current_legislators do
    request(config(:legislators))
  end

  def social_media do
    request(config(:social_media))
  end

  defp request(resource) do
    response = HTTPoison.get!(config(:base_url) <> resource)
    Jason.decode!(response.body)
  end

  defp config(key) do
    Application.get_env(:almanack, :usio_api)[key]
  end
end
