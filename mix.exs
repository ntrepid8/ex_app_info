defmodule ExAppInfo.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_app_info,
     version: "0.3.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package(),

     # docs
     name: "ExAppInfo",
     source_url: "https://github.com/ntrepid8/ex_app_info",
     docs: [cannonical: "https://hexdocs.com/ex_app_info",
            extras: ["README.md", "CHANGELOG.md"]]
   ]
  end

  # app config
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # dependencies
  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev}]
  end

  defp description do
    """
    Helper mix tasks that are useful with CI systems.
    """
  end

  defp package do
    [name: :ex_app_info,
     files: ["lib", "mix.exs", "README.md", "LICENSE", "CHANGELOG.md"],
     maintainers: ["Josh Austin"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/ntrepid8/ex_app_info"}]
  end

end
