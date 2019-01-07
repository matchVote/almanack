defmodule Almanack.MixProject do
  use Mix.Project

  def project do
    [
      app: :almanack,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Almanack.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0.4"},
      {:httpoison, "~> 1.4.0"},
      {:nimble_csv, "~> 0.5.0"},
      {:poison, "~> 3.1.0"},
      {:postgrex, "~> 0.14.1"}
    ]
  end
end
