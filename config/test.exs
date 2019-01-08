use Mix.Config

config :almanack, Almanack.Repo,
  database: "almanack_test",
  username: "postgres",
  password: "postgres",
  hostname: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox
