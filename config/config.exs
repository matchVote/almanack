use Mix.Config

config :almanack, :usio_api,
  base_url: "https://theunitedstates.io/congress-legislators/",
  legislators: "legislators-current.json",
  social_media: "legislators-social-media.json",
  executives: "executive.json"

config :almanack, :nga_api,
  governors_addresses:
    "https://www.nga.org/wp-content/uploads/2019/01/Governors-Mailing-Addresses.xlsx"

config :almanack, :gci_api,
  base_url: "https://www.googleapis.com/civicinfo/v2/",
  representatives: "representatives"

config :almanack, :ballotpedia,
  top_mayors_url:
    "https://ballotpedia.org/List_of_current_mayors_of_the_top_100_cities_in_the_United_States"

config :almanack, ecto_repos: [Almanack.Repo]

config :logger, level: :info
config :logger, :console, format: "$date $time $metadata[$level] $levelpad$message\n"

import_config "#{Mix.env()}.exs"
