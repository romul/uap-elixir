defmodule UserAgentParser.Mixfile do
  use Mix.Project

  def project do
    [app: :user_agent_parser,
     version: "1.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     # Hex
     description: description,
     package: package]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end

  defp description do
    """
    A simple Elixir package for parsing user agent strings with the help of BrowserScope's UA database
    """
  end

  defp package do
    [# These are the default files included in the package
     files: ["lib", "config", "mix.exs", "README.md", "vendor/uap-core/regexes.yaml"],
     maintainers: ["Roman Smirnov"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/romul/uap-elixir"}]
  end
end
