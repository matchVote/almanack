defmodule Almanack.Sources.USIO.API do
  @spec current_legislators() :: [map]
  def current_legislators do
    request(config(:legislators))
  end

  @spec social_media() :: [map]
  def social_media do
    request(config(:social_media))
  end

  @spec executives() :: [map]
  def executives do
    request(config(:executives))
  end

  defp request(resource) do
    response = HTTPoison.get!(config(:base_url) <> resource)
    Jason.decode!(response.body)
  end

  defp config(key) do
    Application.get_env(:almanack, :usio_api)[key]
  end
end
