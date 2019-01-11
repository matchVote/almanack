defmodule Almanack.Fixtures do
  def load(filename) do
    Poison.decode!(File.read!("test/fixtures/#{filename}"))
  end
end
