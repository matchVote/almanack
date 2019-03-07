defmodule Almanack.Sources.GoogleCivicInfo do
  import Mockery.Macro
  alias __MODULE__.API
  alias Almanack.Sources.NGA

  @spec officials() :: [Ecto.Changeset.t()]
  def officials do
    mockable(NGA).governors_addresses()
    |> Enum.map(fn address ->
      normalize_address(address)
      |> mockable(API).representatives()
      |> IO.inspect()
    end)
  end

  @spec normalize_address(%NGA{}) :: String.t()
  def normalize_address(address) do
    "#{address.line1} #{address.city} #{address.state} #{address.zip}"
  end

  defmodule API do
    @spec representatives(String.t()) :: [map]
    def representatives(address) do
      request(config(:representatives), address)
    end

    defp request(resource, address) do
      response =
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
