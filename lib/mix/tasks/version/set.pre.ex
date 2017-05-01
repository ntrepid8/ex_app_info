defmodule Mix.Tasks.ExAppInfo.Version.Set.Pre do
  @moduledoc """
  Set the PRE version in the project version with the given argument.
  ```
  Usage: mix ex_app_info.version.set.pre VERSION [VERSION] [VERSION]
  ```

  Additional VERSIONS are joined with a `.`

  ## Command line options

    - `--clear` - removes PRE version completely
  """
  use Mix.Task

  # task properties
  @shortdoc "set the project PRE version"

  # other properties
  @pre_meta_data_re ~r/^[0-9A-Za-z-]+$/
  @semver_org "http://semver.org/"

  def run(args) do
    op_opts = [
      strict: [clear: :boolean],
    ]
    OptionParser.parse(args, op_opts)
    |> handle_parsed_options()
    |> case do
      {:error, reason} ->
        Mix.shell.error("error: #{reason} see: #{@semver_org}")
        Kernel.exit({:shutdown, 1})
      {:ok, {old_version, new_version}} ->
        Mix.shell.info("version updated: #{old_version} to #{new_version}")
    end
  end

  # Helpers
  ## invalid args
  defp handle_parsed_options({[], [], _invalid}) do
    {:error, "pre version argument or --clear flag is required"}
  end

  ## handle just the --clear flag
  defp handle_parsed_options({[clear: true], [], _invalid}) do
    update_pre_meta_data([])
  end

  defp handle_parsed_options({[clear: true], [_h|_t], _invalid}) do
    {:error, "pre version argument or --clear flag is required (not both)"}
  end

  ## handle raw new_version argument
  defp handle_parsed_options({_parsed, raw_new_pre_versions, _invalid}) do
    Enum.all?(raw_new_pre_versions, fn(raw_new_pre_version) ->
      Regex.match?(@pre_meta_data_re, raw_new_pre_version)
    end)
    |> case do
      true  -> update_pre_meta_data(raw_new_pre_versions)
      false -> {:error, "invalid pre versions: #{inspect raw_new_pre_versions}"}
    end
  end

  defp update_pre_meta_data(raw_new_pre_versions) do
    with {:ok, {old_version, new_version}} <- ExAppInfo.update_version_part(:pre, raw_new_pre_versions),
         :ok <- ExAppInfo.update_mix_exs_version(new_version),
      do: {:ok, {old_version, new_version}}
  end

end
