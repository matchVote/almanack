defmodule Almanack.Scheduler do
  use GenServer
  alias Almanack.Loaders

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, [], {:continue, nil}}
  end

  def handle_continue(nil, state) do
    execute_loaders()
    {:noreply, state}
  end

  defp execute_loaders do
    # - Static files
    # - Async:
    #   - Congress (USIO)
    #   - Presidents (USIO)
    #   - Governors (GCD)
    #   - Mayors (Ballotpedia top 100 scraper, GCD)
    Loaders.Congress.start()
    cooldown()
  end

  defp cooldown() do
    Process.send_after(
      self(),
      :execute_loaders,
      Application.get_env(:almanack, :loader_cooldown)
    )
  end
end
