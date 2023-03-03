defmodule ZendeskSupportAPI.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :zendesk_support_api,
      version: @version,
      elixir: "~> 1.11",
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
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.0"}
    ]
  end
end
