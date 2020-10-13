defmodule Brain.Persist do
  alias Brain.Memory

  require Logger

  def get_all_memories() do
    Application.get_env(:brain, :memory_paths, [])
    |> Enum.map(fn memory_path ->
      Path.join([memory_path |> Path.expand(), "*.md"])
      |> Path.wildcard()
      |> Enum.map(fn x ->
        with {:ok, markdown} <- File.read(x),
             {:ok, memory} <- Memory.get(markdown) do
          {:ok, memory}
        else
          err ->
            {:error, err}
        end
      end)
      |> Enum.filter(fn x ->
        case x do
          {:ok, _memory} ->
            true

          err ->
            Logger.warn("malformed memory found: #{inspect(err)}")
            false
        end
      end)
      |> Enum.map(fn {:ok, memory} ->
        memory
      end)
    end)
    |> List.flatten()
  end
end
