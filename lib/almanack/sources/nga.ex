defmodule Almanack.Sources.NGA do
  alias __MODULE__.API

  @temp_xlsx_file "gvn_adds.xlsx"

  @spec governors_addresses() :: [map]
  def governors_addresses do
    download_addresses()
    extract_addresses()
  end

  defp download_addresses do
    File.write!(@temp_xlsx_file, API.governors_addresses())
  end

  defp extract_addresses do
    [headers | addresses] = parse_xlsx()

    Enum.map(addresses, fn address ->
      Enum.zip(headers, address)
      |> Map.new()
    end)
  end

  defp parse_xlsx do
    Xlsxir.multi_extract(@temp_xlsx_file)[:ok]
    |> Xlsxir.get_list()
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
