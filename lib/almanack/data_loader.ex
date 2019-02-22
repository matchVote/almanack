defmodule Almanack.DataLoader do
  use GenServer
  require Logger
  alias Almanack.Sources.USIO
  alias Almanack.Officials.{Enrichment, Official}

  @spec run() :: any
  def run do
    Logger.info("Starting data load...")

    USIO.officials()
    |> enrich_officials()
    |> upsert_officials()

    Logger.info("Finished.\n")
  end

  defp enrich_officials(officials) do
    Enum.map(officials, fn official ->
      official
      |> Enrichment.generate_slug()
      |> Enrichment.format_gender()
      |> Enrichment.downcase_religion()
    end)
  end

  defp upsert_officials(officials) do
    Enum.each(officials, fn official ->
      terms = Official.get_change(official, :terms)
      official = Ecto.Changeset.delete_change(official, :terms)

      official
      |> Almanack.Repo.insert!(
        on_conflict: {:replace, Official.replace_fields()},
        conflict_target: :mv_key
      )
    end)

    Logger.info("#{length(officials)} officials upserted")
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    send(self(), :work)
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
end
