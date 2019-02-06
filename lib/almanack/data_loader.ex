defmodule Almanack.DataLoader do
  use GenServer
  require Logger
  alias Almanack.Sources.USIO

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    schedule_loader()
    {:ok, []}
  end

  def handle_info(:work, state) do
    Task.start_link(__MODULE__, :run, [])
    schedule_loader()
    {:noreply, state}
  end

  defp schedule_loader() do
    Process.send_after(
      self(),
      :work,
      Application.get_env(:almanack, :data_load_cooldown)
    )
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
        on_conflict: {:replace, Almanack.Official.replace_fields()},
        conflict_target: :bioguide_id
      )
    end)

    Logger.info("Finished. #{length(officials)} officials upserted.")
  end
end
