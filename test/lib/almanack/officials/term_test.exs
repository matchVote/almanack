defmodule Almanack.Officials.TermTest do
  use Almanack.RepoCase
  alias Almanack.Officials.{Official, Term}

  test "emails defaults to empty list" do
    term = Repo.insert!(%Term{})
    assert term.emails == []

    term = Repo.get(Term, term.id)
    assert term.emails == []
  end

  test "terms are unique by start_date and official_id" do
    term =
      Term.new(
        official_id: Repo.insert!(%Official{mv_key: "some-one"}).id,
        start_date: "1987-02-01"
      )

    Repo.insert!(term)
    assert {:error, cs} = Repo.insert(term)
    {msg, constraint} = cs.errors[:official_id]
    assert msg == "has already been taken"
    assert constraint[:constraint_name] == "terms_official_id_start_date_index"
  end
end
