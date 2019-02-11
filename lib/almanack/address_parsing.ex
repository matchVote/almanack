defmodule Almanack.AddressParsing do
  @address_regex ~r/\A(?<line1>(.+))\s(?<city>(\w+))\s(?<state>(\w{2}))\s(?<zip>(\d{5}(-\d{4})?))\z/

  @doc """
  Parses given address string into a map
  """
  @spec parse(nil) :: map
  def parse(nil) do
    %{
      "line1" => "",
      "city" => "",
      "state" => "",
      "zip" => ""
    }
  end

  @spec parse(String.t()) :: map
  def parse(address) do
    Regex.named_captures(@address_regex, String.downcase(address))
    |> Map.update!("line1", &capitalize_words/1)
    |> Map.update!("city", &capitalize_words/1)
    |> Map.update!("state", &String.upcase/1)
  end

  @spec capitalize_words(String.t()) :: String.t()
  defp capitalize_words(value) do
    value
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
