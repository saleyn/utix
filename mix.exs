defmodule Utix.MixProject do
  use Mix.Project

  def project do
    Code.compile_file("lib/utix.ex")
    [
      app:             :utix,
      version:         Utix.app_version(),
      elixir:          "~> 1.15-rc",
      start_permanent: Mix.env() == :prod,
      deps:            deps(),
      elixirc_paths:   elixirc_paths(),
      elixirc_options: [ignore_module_conflict: true],
      package:         package(),
      dialyzer:        dialyzer(),
      # Docs
      name:            "Utix",
      description:     "Elixir Utility Library",
      homepage_url:    "http://github.com/saleyn/utix",
      authors:         ["Serge Aleynikov"],
      docs:            [
        main:          "Utix", # The main page in the docs
        extras:        ["README.md"]
      ],
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
      {:ex_check, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:credo,    ">= 0.0.0", only: :dev, runtime: false},
      {:ex_doc,   ">= 0.0.0", only: :dev, runtime: false},
    ]
  end

  defp package() do
    [
      # These are the default files included in the package
      licenses: ["BSD"],
      links:    %{"GitHub" => "https://github.com/saleyn/utix"},
      files:    ~w(lib test mix.exs Makefile README* LICENSE* CHANGELOG*)
    ]
  end

  defp elixirc_paths(), do: (Mix.env() == :test && ["lib", "test"]) || ["lib"]

  # Dialyzer configuration
  defp dialyzer do
    [
      # Use a custom PLT directory for continuous integration caching.
      plt_core_path:   System.get_env("PLT_DIR"),
      plt_add_deps:    :app_tree,
      flags:           [
      ],
      #ignore_warnings: ".dialyzer_ignore"
    ]
  end

end
