defmodule Almanack.Officials.TermTest do
  use Almanack.RepoCase
  alias Almanack.Officials.Term

  test "emails defaults to empty list" do
    term = Repo.insert!(%Term{})
    assert term.emails == []

    term = Repo.get(Term, term.id)
    assert term.emails == []
  end
end
