use Mix.Config

config :almanack, Almanack.Repo,
  database: "matchvote_dev",
  username: "postgres",
  password: "postgres",
  hostname: "host.docker.internal",
  port: 5653
