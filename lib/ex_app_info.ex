defmodule ExAppInfo do
  @moduledoc """
  Documentation for ExAppInfo.

  A set of helpers for dealing with App/Project info values. Useful
  for integration with CI systems like Jenkins or Travis.
  """

  @mix_exs "mix.exs"
  @project_version_re ~r/version:[ ]*"([a-zA-Z0-9-\.\+]+)"/

  @doc """
  Replace the version value in the project "mix.exs" file.
  """
  def update_mix_exs_version(new_version) do
    with {:ok, data} <- File.read(@mix_exs),
         new_data = Regex.replace(@project_version_re, data, "version: \"#{new_version}\""),
      do: File.write(@mix_exs, new_data)
  end

  @doc """
  Update a single component of the version.

  ## returns
  - `{:ok, {old_version, new_version}}`
  - `{:error, reason}`

  ## Examples

      iex> update_version_part(:build, "12345")
  """
  def update_version_part(key, new_value, opts \\ []) do
    case run_update_version_part(key, new_value, opts) do
      :error           -> {:error, "invalid #{key} version: #{inspect new_value}"}
      {:error, reason} -> {:error, reason}
      {:ok, success}   -> {:ok, success}
    end
  end

  # Private helpers
  defp run_update_version_part(key, new_value, opts) do
    with project_config <- Mix.Project.config(),
         old_version <- Keyword.get(project_config, :version),
         {:ok, version} <- Version.parse(old_version),
         new_version_exact <- struct(version, %{key => new_value}),
         {:ok, new_version_parsed} <- Version.parse("#{new_version_exact}")
      do
        case Keyword.get(opts, :exact, false) do
          true  -> {:ok, {old_version, new_version_exact}}
          false -> {:ok, {old_version, new_version_parsed}}
        end
      end
  end

end
