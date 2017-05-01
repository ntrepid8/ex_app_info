defmodule Mix.Tasks.ExAppInfo.Version.Set.Build do
  @moduledoc """
  Set the BUILD version in the project version with the given argument.
  ```
  Usage: mix ex_app_info.version.set.build VERSION
  ```

  ## Command line options

    - `--clear` - removes BUILD version completely
  """
  use Mix.Task

  # task properties
  @shortdoc "set the project BUILD version"

  # other properties
  @build_meta_data_re ~r/^[0-9A-Za-z-\.]+$/
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
    {:error, "build version argument or --clear flag is required"}
  end

  ## handle just the --clear flag
  defp handle_parsed_options({[clear: true], [], _invalid}) do
    update_build_meta_data(nil)
  end

  defp handle_parsed_options({[clear: true], [raw_new_build_meta_data|_], _invalid}) do
    {:error, "build version argument or --clear flag is required (not both)"}
  end

  ## handle raw new_version argument
  defp handle_parsed_options({_parsed, [raw_new_build_meta_data|_], _invalid}) do
    cond do
      # if the empty string is passed, nil the build version
      raw_new_build_meta_data == "" ->
        update_build_meta_data(nil)
      # if a valid build version is passed, set it
      Regex.match?(@build_meta_data_re, raw_new_build_meta_data) ->
        update_build_meta_data(raw_new_build_meta_data)
      # error
      true ->
        {:error, "invalid build_meta_data: #{inspect raw_new_build_meta_data}"}
    end
  end

  defp update_build_meta_data(new_build_meta_data) do
    with {:ok, {old_version, new_version}} <- ExAppInfo.update_version_part(:build, new_build_meta_data),
         :ok <- ExAppInfo.update_mix_exs_version(new_version),
      do: {:ok, {old_version, new_version}}
  end

end
