defmodule Almanack.Repo do
  use Ecto.Repo,
    otp_app: :almanack,
    adapter: Ecto.Adapters.Postgres
end
