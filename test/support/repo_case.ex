defmodule Almanack.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Almanack.TestCase
      alias Almanack.Repo

      import Ecto
      import Ecto.Query
      import Almanack.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Almanack.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Almanack.Repo, {:shared, self()})
    end

    :ok
  end
end
