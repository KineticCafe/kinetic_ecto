defmodule KineticEctoExtensions.MixProject do
  use Mix.Project

  def project do
    [
      app: :kinetic_ecto,
      version: "1.1.1",
      description: "Extensions for Ecto previously used at Kinetic Commerce",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "KineticEcto",
      source_url: "https://github.com/KineticCafe/kinetic_ecto",
      docs: docs(),
      package: [
        files: ~w(lib .formatter.exs mix.exs *.md),
        licenses: ["Apache-2.0"],
        links: %{
          "Source" => "https://github.com/KineticCafe/kinetic_ecto",
          "Issues" => "https://github.com/KineticCafe/kinetic_ecto/issues"
        }
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.github": :test,
        "coveralls.html": :test
      ],
      test_coverage: test_coverage(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_local_path: "priv/plts/project.plt",
        plt_core_path: "priv/plts/core.plt"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.10"},
      {:ecto_sql, "~> 3.10", optional: true},
      # {:postgrex, ">= 0.0.0", optional: true},
      # {:plug_crypto, "~> 1.0 or ~> 2.0", optional: true},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:castore, "~> 1.0", only: [:test]},
      {:ecto_sqlite3, "~> 0.17", only: [:test]},
      {:excoveralls, "~> 0.18", only: [:test]},
      {:ex_doc, "~> 0.29", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.2", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CONTRIBUTING.md": [filename: "CONTRIBUTING.md", title: "Contributing"],
        "CODE_OF_CONDUCT.md": [filename: "CODE_OF_CONDUCT.md", title: "Code of Conduct"],
        "CHANGELOG.md": [filename: "CHANGELOG.md", title: "CHANGELOG"],
        "LICENCE.md": [filename: "LICENCE.md", title: "Licence"],
        "licences/APACHE-2.0.txt": [
          filename: "APACHE-2.0.txt",
          title: "Apache License, version 2.0"
        ],
        "licences/dco.txt": [filename: "dco.txt", title: "Developer Certificate of Origin"]
      ]
    ]
  end

  defp elixirc_paths(:test) do
    ~w(lib test/support)
  end

  defp elixirc_paths(_) do
    ~w(lib)
  end

  defp test_coverage do
    [
      tool: ExCoveralls,
      ignore_modules: [KineticEcto.TestImage, KineticEcto.TestImage.HSLA, KineticEcto.TestImage.RGBA]
    ]
  end
end
