defmodule Almanack.Sources.USIO do
  @current_legislators_resource "legislators-current.json"
  @social_media_resource "legislators-social-media.json"

  def data do
    officials = request_data(@current_legislators_resource)
    # social_media_ids = request_data(@social_media_resource)
    officials
  end

  defp request_data(resource) do
    response =
      (Application.get_env(:almanack, :usio_url) <> resource)
      |> HTTPoison.get!()

    response.body
    |> Poison.decode!()
  end
end
