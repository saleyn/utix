defmodule Utix do
  @moduledoc """
  Miscellaneous helper functions
  """

  defmodule Exception do
    @moduledoc """
    General exception with an optional string or map stored in exception details
    """
    defexception [:message, :details]

    def message(%__MODULE__{} = exception) do
      pfx = "** (Exception) "
      case exception.message do
        nil -> pfx <>        details(exception.details)
        val -> pfx <> val <> details(exception.details)
      end
    end

    defp details(e) when is_map(e),    do: ": " <> (Map.to_list(e) |> inspect())
    defp details(e) when is_binary(e), do: ": " <> e
    defp details(nil),                 do: ""
    defp details(e),                   do: ": " <> inspect(e)
  end

  @doc """
  Generate `*.config` system config files from the files found in the `config`
  directory.
  """
  @spec write_sys_configs!(String.t(), [String.t()]) :: [String.t()]
  def   write_sys_configs!(out_file_sfx \\ "sys.config", exclude_basenames \\ []) do
    excluded = ["config"] ++ exclude_basenames
    "config/*.exs"
    |> Path.wildcard()
    |> Enum.map(& Path.basename(&1, ".exs"))
    |> Enum.reject(& &1 =~ "runtime")
    |> Enum.filter(& &1 not in excluded)
    |> Enum.map(fn env ->
      env
      |> String.to_atom()
      |> write_sys_config!(Path.join("config", env <> ".exs"), out_file_sfx)
    end)
  end

  @doc """
  Generate system config file (defaults to `${env}.sys.config`) from the Elixir
  `config_filename` provided in the input.
  """
  @spec write_sys_config!(atom(), String.t(), String.t()) :: String.t()
  def   write_sys_config!(env, config_file, out_file_sfx \\ "sys.config")
    when is_atom(env) and is_binary(config_file)
  do
    config =
      config_file
      |> Config.Reader.read!()
      |> then(& :io_lib.format("~p.\n", [&1]))  ## Format it nicely
      |> List.to_string()
    file = "#{env}.#{Path.basename(out_file_sfx)}"
    out_file =
      out_file_sfx
      |> Path.dirname()
      |> Path.join(file)
    :ok = File.write!(out_file, config)
    out_file
  end

  @doc """
  If the list length is not greater than `max_len`, stringify it.  Otherwise
  return the item count in the list as a string.
  """
  @spec str_or_count(list, non_neg_integer) :: binary
  def   str_or_count(list, max_len \\ 10) when is_list(list) do
    case length(list) do
      n when n > max_len -> Integer.to_string(n)
      _                  -> inspect(list)
    end
  end

  @doc """
  Obtain the version of the current application.

  This macro must only be called from a Mix project file.

  ## Why is this neeed?

  When a mix project version is hard-coded in the `mix.exs` file, it is easy
  to get it out of sync with the latest tag in the git history, or the latest
  git revision.  With this method, the app version is automatically determined
  either from the `hex.pm`'s metadata or from git history and is used to set
  the application version in the generated `*.app` file.

  If the project is loaded as a dependency from Hex.pm, then the project
  contains ".hex" file, which contains the version.  If it's loaded from git,
  then we can use "git describe" command to format the version with a revision.

  The macro will raise an exception if it cannot determine the version using
  the methods described above.

  ## NOTE

  with this method of calculating the version number, you need to make
  sure that in the Github action the checkout includes:
  ```
    - name: Checkout the repository
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
  ```
  This ensures that the git history is checked out with tags so that
  `git describe --tags` returns the proper version number.
  """
  @spec app_version!() :: binary
  def   app_version!() do
    hex_spec = Mix.Project.deps_path() |> Path.dirname() |> Path.join(".hex")
    version =
      if File.exists?(hex_spec) do
        hex_spec
        |> File.read!()
        |> :erlang.binary_to_term()
        |> elem(1)
        |> Map.get(:version)
      else
        with {ver, 0} <-
              System.cmd("git", ~w(describe --always --tags),
                stderr_to_stdout: true
              ) do
          ver
          |> String.trim()
          |> String.replace(~r/^v/, "")
        else _ ->
          raise "Cannot determine application version!"
        end
      end
    version
  end
end
