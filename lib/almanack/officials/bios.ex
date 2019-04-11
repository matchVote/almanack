defmodule Almanack.Officials.Bios do
  import Ecto.Query
  import Mockery.Macro
  alias __MODULE__.Wikipedia
  alias Almanack.Repo
  alias Almanack.Officials.Official

  @default_bio "To Be Added"

  @spec load() :: :ok
  def load do
    Task.Supervisor.async_stream(
      Almanack.BioSupervisor,
      officials_without_bios(),
      &generate_bio/1
    )
    |> Enum.each(fn {:ok, official} ->
      Repo.update!(official)
    end)
  end

  @spec officials_without_bios() :: [Official]
  def officials_without_bios do
    from(o in Official, where: is_nil(o.bio))
    |> Repo.all()
  end

  @spec generate_bio(Official) :: Ecto.Changeset.t()
  def generate_bio(official) do
    bio =
      with key when is_binary(key) <- official.identifiers["wikipedia"] do
        mockable(Wikipedia).request_bio(key)
        |> Wikipedia.extract_bio(@default_bio)
      else
        nil ->
          @default_bio
      end

    Official.changeset(official, %{bio: bio})
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

    @spec extract_bio(map, String.t() | nil) :: String.t()
    def extract_bio(data, default \\ nil) do
      data["query"]["pages"]
      |> Map.values()
      |> List.first()
      |> Map.get("extract", default)
    end
  end
end
