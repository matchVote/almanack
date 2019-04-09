defmodule Almanack.Officials.Bios do
  import Ecto.Query
  import Mockery.Macro
  alias __MODULE__.Wikipedia
  alias Almanack.Repo
  alias Almanack.Officials.Official

  @default_bio "To Be Added"

  @spec load() :: :ok
  def load do
    officials_without_bios()
    |> Enum.map(fn official ->
      case official.identifiers["wikipedia"] do
        nil ->
          Official.changeset(official, %{bio: @default_bio})

        key ->
          bio =
            mockable(Wikipedia).request_bio(key)
            |> Wikipedia.extract_bio(@default_bio)

          Official.changeset(official, %{bio: bio})
      end
    end)
    |> Enum.each(fn cs ->
      Repo.update!(cs)
    end)
  end

  defp officials_without_bios do
    from(o in Official, where: is_nil(o.bio))
    |> Repo.all()
  end

  defmodule Wikipedia do
    @spec request_bio(String.t()) :: map
    def request_bio(key) do
      key
      |> sanitize()
      |> generate_url()
      |> request()
    end

    defp sanitize(key) do
      String.replace(key, " ", "%20")
    end

    defp generate_url(key) do
      base = Application.get_env(:almanack, :wikipedia)[:base_url]
      opts = "&redirects=true&prop=extracts&exintro=&explaintext="
      "#{base}#{opts}&titles=#{key}"
    end

    defp request(url) do
      response = HTTPoison.get!(url)
      Jason.decode!(response.body)
    end

    @spec extract_bio(map, String.t()) :: String.t()
    def extract_bio(data, default_bio) do
      data["query"]["pages"]
      |> Map.values()
      |> List.first()
      |> Map.get("extract", default_bio)
    end
  end
end
