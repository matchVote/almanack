defmodule Almanack.Fixtures do
  @spec load(String.t()) :: String.t()
  def load(filename) do
    _load(filename, Path.extname(filename))
  end

  defp _load(filename, ".json") do
    Poison.decode!(load_file(filename))
  end

  defp _load(filename, _) do
    load_file(filename)
  end

  defp load_file(filename) do
    File.read!("test/fixtures/#{filename}")
  end
end
