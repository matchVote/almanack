defmodule Almanack.DataLoader do
  alias Almanack.Sources.USIO

  def run do
    USIO.legislators()
    |> USIO.include_social_media()
    |> upsert_officials()
  end

  defp upsert_officials(officials) do
    Enum.each(officials, fn official ->
      official
      |> Almanack.Official.changeset()
      |> Almanack.Repo.insert(
        on_conflict: :replace_all_except_primary_key,
        conflict_target: :bioguide_id
      )
    end)
  end
end
