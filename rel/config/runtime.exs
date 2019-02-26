use Mix.Config

config :almanack, Almanack.Repo,
  database: System.get_env("DB_NAME"),
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  hostname: System.get_env("DB_HOST"),
  port: System.get_env("DB_PORT")

config :almanack,
  # 1 day default
  loader_cooldown: System.get_env("DATA_LOAD_COOLDOWN") || 86_400_000_000

config :logger, level: System.get_env("LOG_LEVEL") || :info
