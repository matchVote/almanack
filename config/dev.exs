use Mix.Config

config :almanack, Almanack.Repo,
  database: "matchvote_dev",
  username: "postgres",
  password: "postgres",
  hostname: "host.docker.internal",
  port: 5653

config :almanack, data_load_cooldown: 10_000
