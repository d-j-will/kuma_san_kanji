defmodule KumaSanKanji.MixProject do
  use Mix.Project

  def project do
    [
      app: :kuma_san_kanji,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      deps: deps()
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {KumaSanKanji.Application, []},
      extra_applications: [:logger, :runtime_tools, :ash] ++ dev_applications()
    ]
  end

  # Development-only applications that aren't available in production Docker images
  defp dev_applications do
    if Mix.env() == :dev do
      [:wx, :observer]
    else
      []
    end
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:picosat_elixir, "~> 0.2"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:phoenix, "~> 1.8"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      # Floki needed at runtime for KanjiVG SVG sanitization (was test-only)
      {:floki, ">= 0.36.0"},
      {:mimic, "~> 2.2", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.4", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2"},
      {:bandit, "~> 1.5"},

      # Ash Framework dependencies
      {:ash, "~> 3.5"},
      {:ash_phoenix, "~> 2.3"},
      {:ash_authentication, "~> 4.1"},
      {:igniter, "~> 0.6"},
      {:ash_postgres, "~> 2.4"},
      {:usage_rules, "~> 0.1"},

      # Password hashing (used by AshAuthentication password strategy)
      {:bcrypt_elixir, "~> 3.0"},
      # MCP Integration
      # Property-based testing (Ash already depends on stream_data ~> 1.0)
      {:stream_data, "~> 1.0"},
      {:tidewave, "~> 0.5", only: [:dev]},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},

      # Feature flags
      {:fun_with_flags, "~> 1.13"},
      {:fun_with_flags_ui, "~> 1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "usage_rules.update": [
        """
        usage_rules.sync AGENTS.md --all \
          --inline usage_rules:all \
          --link-to-folder deps
        """
        |> String.trim()
      ],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      setup: ["deps.get", "assets.setup", "assets.build", "ecto.setup", "run priv/repo/seeds.exs"],
      quality: ["format --check-formatted", "credo --strict"],
      "test.coverage": ["coveralls.html"],
      "assets.setup": [
        "tailwind.install --if-missing",
        "esbuild.install --if-missing",
        "cmd npm install --prefix assets"
      ],
      "assets.build": ["cmd npm run deploy --prefix assets", "esbuild kuma_san_kanji"],
      "assets.deploy": [
        "cmd npm run deploy --prefix assets",
        "esbuild kuma_san_kanji --minify",
        "phx.digest"
      ],
      # Run full Phoenix endpoint (which already plugs Tidewave in endpoint.ex)
      # instead of starting Tidewave standalone (which caused: "no Phoenix endpoint found")
      tidewave: "phx.server"
    ]
  end
end
