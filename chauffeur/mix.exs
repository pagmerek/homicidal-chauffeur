defmodule Chauffeur.MixProject do
  use Mix.Project

  def project do
    [
      app: :chauffeur,
      version: "0.1.0",
      elixir: "~> 1.9",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Chauffeur, []},
      extra_applications: [:crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.11.0"},
      {:scenic_driver_local, "~> 0.11.0"},
      {:scenic_live_reload, "~> 0.3", only: :dev},
      {:math, "~> 0.3.0"}
    ]
  end
end
