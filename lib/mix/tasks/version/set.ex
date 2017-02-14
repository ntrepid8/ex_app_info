defmodule Mix.Tasks.ExAppInfo.Set do
  @moduledoc """
  Set the project version with the given argument.
  """
  use Mix.Task

  @shortdoc "set the project version"
  @mix_exs "mix.exs"
  @project_version_re ~r/version:[ ]*"([a-zA-Z0-9-\.\+]+)"/

  def run(args) do
    OptionParser.parse(args)
    |> handle_parsed_options()
    |> case do
      {:error, reason} ->
        Mix.shell.error("error: #{reason}")
        Kernel.exit({:shutdown, 1})
      {:ok, {old_version, new_version}} ->
        Mix.shell.info("version updated: #{old_version} to #{new_version}")
    end
  end

  # Helpers
  ## no argument error
  defp handle_parsed_options({_parsed, [], _invalid}) do
    {:error, "version argument is required"}
  end

  ## handle raw new_version argument
  defp handle_parsed_options({_parsed, [raw_new_version|_], _invalid}) do
    case Version.parse(raw_new_version) do
      :error -> "invalid new_version: #{inspect raw_new_version}"
      {:ok, new_version}
    end
  end

  defp handle_new_version(new_version) do
    with project_config <- Mix.Project.config(),
         old_version <- Keyword.get(:version),
         :ok <- update_mix_exs(new_version),
      do: {:ok, {old_version, new_version}}
  end

  defp update_mix_exs(new_version) do
    with {:ok, data} <- File.read(@mix_exs),
         new_data = Regex.replace(@project_version_re, data, "version: \"#{new_version}\""),
      do: File.write(@mix_exs, new_data)
  end
end
