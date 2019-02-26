defmodule Almanack.Loaders.Congress do
  require Logger
  alias Almanack.Repo
  alias Almanack.Sources.USIO
  alias Almanack.Officials.{Enrichment, Official}

  def start do
    Task.Supervisor.start_child(Almanack.LoaderSupervisor, __MODULE__, :run, [])
  end

  @spec run() :: any
  def run do
    Logger.info("Starting Congress loader...")

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
end
