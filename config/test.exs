use Mix.Config

config :almanack, Almanack.Repo,
  database: "almanack_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, backends: []
