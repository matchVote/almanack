defmodule Almanack.Sources.VoteView do
  alias NimbleCSV.RFC4180, as: CSV

  def data do
    request_data()
    |> convert_csv_rows_to_maps
  end

  defp request_data do
    response =
      Application.get_env(:almanack, :voteview_url)
      |> HTTPoison.get!()

    response.body
  end

  @spec convert_csv_rows_to_maps(String.t()) :: [map]
  defp convert_csv_rows_to_maps(csv) do
    headers = extract_headers(csv)

    csv
    |> CSV.parse_string()
    |> Enum.reduce(%{}, fn row, acc ->
      data =
        Enum.zip(headers, row)
        |> Map.new()

      Map.update(acc, data["bioguide_id"], [data], &[data | &1])
    end)
  end

  defp extract_headers(csv) do
    String.splitter(csv, "\n")
    |> Enum.at(0)
    |> String.split(",")
  end
end
