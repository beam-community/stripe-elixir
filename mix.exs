defmodule Stripe.Mixfile do
  use Mix.Project

  def project do
    [
      app: :stripity_stripe,
      deps: deps(),
      description: description(),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_file: {:no_warn, "priv/plts/stripity_stripe.plt"}
      ],
      elixir: "~> 1.5",
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls],
      version: "2.2.3",
      source_url: "https://github.com/code-corps/stripity_stripe/"
    ]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: apps(Mix.env()),
      env: env(),
      mod: {Stripe, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp env() do
    [
      api_base_url: "https://api.stripe.com/v1/",
      api_upload_url: "https://files.stripe.com/v1/",
      pool_options: [
        timeout: 5_000,
        max_connections: 10
      ],
      use_connection_pool: true
    ]
  end

  defp apps(:test), do: apps()
  defp apps(_), do: apps()
  defp apps(), do: [:hackney, :logger, :poison, :uri_query]

  defp deps do
    [
      {:dialyxir, "1.0.0-rc.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.20.2", only: :dev},
      {:excoveralls, "~> 0.8.1", only: :test},
      {:hackney, "~> 1.15"},
      {:inch_ex, "~> 0.5", only: [:dev, :test]},
      {:mox, "~> 0.4", only: :test},
      {:poison, "~> 2.0 or ~> 3.0"},
      {:uri_query, "~> 0.1.2"},
      {:exexec, "~> 0.1.0", only: :test}
    ]
  end

  defp description do
    """
    A Stripe client for Elixir.
    """
  end

  defp package do
    [
      files: ["lib", "LICENSE*", "mix.exs", "README*"],
      licenses: ["New BSD"],
      links: %{
        "GitHub" => "https://github.com/code-corps/stripity_stripe"
      },
      maintainers: ["Dan Matthews", "Josh Smith", "Nikola Begedin", "Scott Newcomer"]
    ]
  end
end
