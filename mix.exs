defmodule Almanack.MixProject do
  use Mix.Project

  def project do
    [
      app: :almanack,
      version: "0.4.3",
      elixir: "~> 1.8.0",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      {:distillery, "~> 2.0.12"},
      {:ecto_sql, "~> 3.0.4"},
      {:floki, "~> 0.20.4"},
      {:httpoison, "~> 1.4.0"},
      {:jason, "~> 1.1.0"},
      {:mockery, "~> 2.3.0", runtime: false},
      {:nimble_csv, "~> 0.5.0"},
      {:poison, "~> 3.1.0"},
      {:postgrex, "~> 0.14.1"},
      {:yaml_elixir, "~> 2.1.0"},
      {:xlsxir, "~> 1.6.4"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
