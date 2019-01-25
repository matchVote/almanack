use Mix.Config

config :almanack, Almanack.Repo,
  database: "almanack_dev",
  username: "postgres",
  password: "postgres",
  hostname: "postgres",
  port: 5432
