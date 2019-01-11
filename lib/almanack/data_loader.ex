defmodule Almanack.DataLoader do
  alias Almanack.Sources.USIO

  def run do
    USIO.legislators()
    |> USIO.include_social_media()
  end
end
