defmodule Almanack.DataLoader do
  require Logger
  use Task
  alias Almanack.Sources.USIO

  def start_link([]) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    Logger.info("Starting data load...")

    USIO.legislators()
    |> USIO.include_social_media()
    |> upsert_officials()
  end

  defp upsert_officials(officials) do
    Enum.each(officials, fn official ->
      official
      |> Almanack.Repo.insert(
        on_conflict: :replace_all_except_primary_key,
        conflict_target: :bioguide_id
      )
    end)

    Logger.info("Finished. #{length(officials)} officials upserted.")
  end
end
