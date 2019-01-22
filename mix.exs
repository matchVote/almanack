defmodule Almanack.MixProject do
  use Mix.Project

  def project do
    [
      app: :almanack,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
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
      {:jason, "~> 1.1.0"},
      {:mockery, "~> 2.3.0", runtime: false},
      {:nimble_csv, "~> 0.5.0"},
      {:poison, "~> 3.1.0"},
      {:postgrex, "~> 0.14.1"}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      reset: ["ecto.drop", "ecto.create", "ecto.migrate"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
