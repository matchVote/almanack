defmodule Almanack.Sources.NGA do
  alias __MODULE__.API

  defstruct [:line1, :city, :state, :zip]

  @temp_xlsx_file "gvn_adds.xlsx"

  @doc """
  Returns a list of structs containing address data points.
  """
  @spec governors_addresses() :: [%__MODULE__{}]
  def governors_addresses do
    download_address_file()
    [headers | addresses] = parse_file()
    remove_file()
    standardize(headers, addresses)
  end

  defp download_address_file do
    File.write!(@temp_xlsx_file, API.governors_addresses())
  end

  defp parse_file do
    Xlsxir.multi_extract(@temp_xlsx_file)[:ok]
    |> Xlsxir.get_list()
  end

  defp remove_file do
    File.rm!(@temp_xlsx_file)
  end

  defp standardize(headers, addresses) do
    Enum.map(addresses, fn address ->
      data =
        Enum.zip(headers, address)
        |> Map.new()

      %__MODULE__{
        line1: data["Mailing Address Line 1"],
        city: data["City"],
        state: data["State"],
        zip: data["Zip Code"]
      }
    end)
  end

  defmodule API do
    @spec governors_addresses() :: String.t()
    def governors_addresses do
      HTTPoison.get!(config(:governors_addresses)).body
    end

    defp config(key) do
      Application.get_env(:almanack, :nga_api)[key]
    end
  end
end
