defmodule Mix.Tasks.ExAppInfo.Version.Set do
  @moduledoc """
  Set the project version with the given argument.
  ```
  Usage: mix ex_app_info.version.set NEW_VERSION [--strict] [--exact]
  ```

  ## Command line options

    - `--strict` - Requires NEW_VERSION to be greater than the current version.
    - `--exact`  - Use NEW_VERSION exactly as passed (if valid).
  """
  use Mix.Task

  # task properties
  @shortdoc "set the project version"

  def run(args) do
    op_opts = [
      strict: [strict: :boolean, exact: :boolean],
    ]
    OptionParser.parse(args, op_opts)
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

  ## no argument error
  defp handle_parsed_options({_parsed, _args, invalid = [_|_]}) do
    {:error, "invalid options: #{inspect invalid}"}
  end

  ## handle raw new_version argument
  defp handle_parsed_options({parsed, [raw_new_version|_], _invalid}) do
    opts = [
      strict: Keyword.get(parsed, :strict, false),
      exact: Keyword.get(parsed, :exact, false),
    ]
    case Version.parse(raw_new_version) do
      :error -> "invalid new_version: #{inspect raw_new_version}"
      {:ok, parsed_new_version} -> handle_new_version(parsed_new_version, raw_new_version, opts)
    end
  end

  defp handle_new_version(parsed_new_version, raw_new_version, [strict: strict, exact: exact]) do
    with project_config <- Mix.Project.config(),
         old_version <- Keyword.get(project_config, :version),
         :ok <- parse_strict_version(parsed_new_version, old_version, strict),
         {:ok, new_version} <- parse_exact_version(parsed_new_version, raw_new_version, exact),
         :ok <- ExAppInfo.update_mix_exs_version(new_version),
      do: {:ok, {old_version, new_version}}
  end

  ## require the new version be greater than the old or not, depending on options passed
  defp parse_strict_version(_new_version, _old_version, false), do: :ok
  defp parse_strict_version(new_version, old_version, true) do
    case Version.compare(new_version, old_version) do
      :gt -> :ok
      _   -> {:error, "strict requires #{new_version} > #{old_version}"}
    end
  end

  ## return the parsed version or the raw version, depending on options passed
  defp parse_exact_version(parsed_version, _raw_version, false), do: {:ok, parsed_version}
  defp parse_exact_version(_parsed_version, raw_version, true), do: {:ok, raw_version}

end
