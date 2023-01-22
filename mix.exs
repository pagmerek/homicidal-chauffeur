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

  def application do
    [
      mod: {Chauffeur.Application, []},
      extra_applications: [:crypto]
    ]
  end

  defp deps do
    [
      # Scenic deps
      {:scenic, "~> 0.11.0"},
      {:scenic_driver_local, "~> 0.11.0"},

      # Math deps
      {:math, "~> 0.3.0"}
    ]
  end
end
