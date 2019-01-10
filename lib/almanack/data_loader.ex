defmodule Almanack.DataLoader do
  def run do
    Almanack.Sources.USIO.legislators()
  end
end
