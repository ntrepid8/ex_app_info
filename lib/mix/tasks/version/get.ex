defmodule Mix.Tasks.ExAppInfo.Version.Get do
  @moduledoc """
  Get the current value for the project version.
  ```
  Usage: mix ex_app_info.version.get
  ```
  """
  use Mix.Task

  @shortdoc "print the project version"

  def run(_args) do
    version =
      Mix.Project.config()
      |> Keyword.get(:version)

    # respond in the shell
    Mix.shell.info("#{version}")
  end
end
