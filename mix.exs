defmodule HTTPMock.MixProject do
  use Mix.Project

  def project do
    [
      app: :httpmock,
      version: "0.1.4",
      name: "HTTPMock",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/andridus/httpmock"
    ]
  end

  defp description() do
    "HTTP mocking for Elixir"
  end

  defp package() do
    [
      name: "httpmock",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/andridus/httpmock"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:httpoison, "~> 1.8", only: :test},
      {:mimic, "~> 1.7", only: :test},
      {:json, "~> 1.4"}
    ]
  end
end
