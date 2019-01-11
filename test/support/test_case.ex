defmodule Almanack.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Mockery
      alias Almanack.Fixtures
    end
  end
end
