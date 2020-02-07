defmodule Brain.MixProject do
  use Mix.Project

  def project do
    [
      app: :brain,
      version: "0.1.0",
      elixir: "~> 1.7",
      escript: [main_module: Brain],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:earmark, "~> 1.4"},
      {:yaml_elixir, "~> 2.4"},
      {:atomic_map, "~> 0.9.3"}
    ]
  end
end
