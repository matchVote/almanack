defmodule Almanack.Sources.USIO do
  def data do
    request_data()
  end

  defp request_data do
    response =
      Application.get_env(:almanack, :usio_url)
      |> HTTPoison.get!()

    response.body
    |> Poison.decode!()
  end
end
