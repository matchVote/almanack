use Mix.Config

config :almanack, :usio_api,
  base_url: "https://theunitedstates.io/congress-legislators/",
  legislators: "legislators-current.json",
  social_media: "legislators-social-media.json",
  executives: "executives.json"

config :almanack, ecto_repos: [Almanack.Repo]

config :logger, level: :info
config :logger, :console, format: "$date $time $metadata[$level] $levelpad$message\n"

import_config "#{Mix.env()}.exs"
