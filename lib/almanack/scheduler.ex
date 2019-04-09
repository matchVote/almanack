defmodule Almanack.Scheduler do
  require Logger
  use GenServer
  alias Almanack.{Repo, Sources}
  alias Almanack.Officials.{Bios, Enrichment, Official, ProfilePics}

  @async_sources [
    Sources.USIO,
    Sources.GoogleCivicInfo,
    Sources.Ballotpedia
  ]

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, [], {:continue, nil}}
  end

  def handle_continue(nil, state) do
    run_workflow()
    {:noreply, state}
  end

  @spec run_workflow() :: any()
  def run_workflow do
    Logger.info("Starting officials ingestion workflow...")

    compile_officials()
    |> enrich_officials()
    |> persist_officials()

    ProfilePics.load()
    # Bios.load()

    cooldown()
    Logger.info("Finished\n")
  end

  @spec compile_officials() :: [Ecto.Changeset.t()]
  def compile_officials do
    officials =
      @async_sources
      |> Enum.reduce([], fn source, officials ->
        # This is actually sync
        apply(source, :officials, []) ++ officials
      end)

    Sources.StaticFiles.officials() ++ officials
  end

  @spec enrich_officials([Ecto.Changeset.t()]) :: [Ecto.Changeset.t()]
  def enrich_officials(officials) do
    Enum.map(officials, fn official ->
      Enrichment.downcase_religion(official)
    end)
  end

  @spec persist_officials([Ecto.Changeset.t()]) :: any()
  def persist_officials(officials) do
    Enum.each(officials, fn official ->
      terms = Official.get_change(official, :terms)

      official =
        official
        |> Ecto.Changeset.delete_change(:terms)
        |> Repo.insert!(
          on_conflict: {:replace, Official.replace_fields()},
          conflict_target: :mv_key,
          returning: true
        )

      insert_or_ignore_terms(terms, official.id)
    end)

    Logger.info("#{length(officials)} officials upserted")
  end

  defp insert_or_ignore_terms(terms, official_id) do
    terms
    |> Enum.each(fn term ->
      Ecto.Changeset.put_change(term, :official_id, official_id)
      |> Repo.insert!(on_conflict: :nothing)
    end)
  end

  defp cooldown() do
    Process.send_after(
      self(),
      :run_workflow,
      Application.get_env(:almanack, :loader_cooldown)
    )
  end
end
