defmodule Mix.Tasks.ExAppInfo.Version.Set.Patch do
@moduledoc """
  Set the PATCH version in the project version with the given argument.
  ```
  Usage: mix ex_app_info.version.set.patch NEW_VERSION
  ```

  ## Command line options

    - `--exact`  - Use NEW_VERSION exactly as passed (if valid).
  """
  use Mix.Task

  # task properties
  @shortdoc "set the project PATCH version"

  # other properties
  @version_re ~r/^[0-9]+$/
  @semver_org "http://semver.org/"

  def run(args) do
    OptionParser.parse(args)
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
  defp handle_parsed_options({_parsed, [], _invalid}) do
    {:error, "build version argument is required"}
  end

  ## handle raw new_version argument
  defp handle_parsed_options({parsed, [raw_new_version|_], _invalid}) do
    update_version_data(raw_new_version, parsed)
  end

  defp update_version_data(raw_new_version, opts \\ []) do
    with {:ok, {old_version, new_version}} <- ExAppInfo.update_version_part(:patch, raw_new_version, opts),
         :ok <- ExAppInfo.update_mix_exs_version(new_version),
      do: {:ok, {old_version, new_version}}
  end

end
