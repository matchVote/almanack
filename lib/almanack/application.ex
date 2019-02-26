defmodule Almanack.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Almanack.Repo,
      {Task.Supervisor, name: Almanack.LoaderSupervisor},
      Almanack.Scheduler
    ]

    opts = [strategy: :one_for_one, name: Almanack.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
