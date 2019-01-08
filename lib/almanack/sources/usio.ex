defmodule Almanack.Sources.USIO do
  import Mockery.Macro
  alias __MODULE__.API

  def data do
    mockable(API).current_legislators()
  end

  defmodule API do
    @current_legislators "legislators-current.json"
    # @social_media_resource "legislators-social-media.json"

    def current_legislators do
      response =
        (Application.get_env(:almanack, :usio_url) <> @current_legislators)
        |> HTTPoison.get!()

      response.body
      |> Poison.decode!()
    end
  end
end
