use Mix.Config

config :almanack, Almanack.Repo,
  database: "matchvote_dev",
  username: "postgres",
  password: "postgres",
  hostname: "host.docker.internal",
  port: 5653

# 10 minutes
config :almanack, loader_cooldown: 600_000
