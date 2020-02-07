defmodule Brain do
  require Logger

  alias Brain.Memory
  alias Brain.Memory.Meta
  alias Brain.Link

  # import Brain.Helper

  def main(args) do
    {parsed_args, _, _} =
      args
      |> OptionParser.parse(
        strict: [
          search: :string,
          tag: :string,
          all: :boolean
        ]
      )

    parsed_args
    |> Map.new()
    |> execute()
    |> IO.puts()
  end

  defp execute(%{all: true}) do
    all_memories = get_all_memories()

    to_graph(
      all_memories,
      all_memories |> get_links()
    )
  end

  defp execute(%{tag: tag}) do
    all_memories = get_all_memories()

    found_memories =
      all_memories
      |> Enum.filter(fn memory ->
        memory
        |> Memory.has_tag?(tag)
      end)

    linked_memories =
      found_memories
      |> get_links()
      |> Enum.map(fn %Link{target_id: target_id} ->
        all_memories
        |> Enum.find(fn %Memory{meta: %Meta{id: id}} -> id == target_id end)
      end)

    to_graph(
      (found_memories ++ linked_memories)
      |> Enum.uniq_by(fn %Memory{meta: %Meta{id: id}} -> id end),
      found_memories |> get_links()
    )
  end

  defp execute(%{search: search}) do
    all_memories = get_all_memories()

    found_memories =
      all_memories
      |> Enum.filter(fn memory ->
        memory
        |> Memory.contains?(search)
      end)

    linked_memories =
      found_memories
      |> get_links()
      |> Enum.map(fn %Link{target_id: target_id} ->
        all_memories
        |> Enum.find(fn %Memory{meta: %Meta{id: id}} -> id == target_id end)
      end)

    parent_memories =
      all_memories
      |> Enum.filter(fn possible_parent_memory ->
        found_memories
        |> Enum.any?(fn found_memory ->
          found_memory
          |> Memory.is_linked?(possible_parent_memory)
        end)
      end)

    links_to_parent =
      parent_memories
      |> Enum.map(fn %Memory{meta: %Meta{links: parent_links}} ->
        parent_links
      end)
      |> List.flatten()
      # |> Enum.uniq_by(fn %Link{id: id} -> id end)
      |> Enum.uniq()
      |> Enum.filter(fn %Link{target_id: linked_id} ->
        found_memories
        |> Enum.map(fn %Memory{meta: %Meta{id: id}} ->
          id
        end)
        |> Enum.any?(fn found_id -> found_id == linked_id end)
      end)

    links =
      links_to_parent
      |> Kernel.++(found_memories |> get_links())
      |> Enum.uniq()

    to_graph(
      (parent_memories ++ found_memories ++ linked_memories)
      |> Enum.uniq_by(fn %Memory{meta: %Meta{id: id}} -> id end),
      links
    )
  end

  defp execute(_) do
    """
    --search phrase
      find memory
    --all
      show complete brain
    --tag name
      find memories by tag
    """
  end

  defp to_graph(memories, links) do
    dot_memories =
      memories
      |> Enum.map(fn %Memory{dot_node: dot} ->
        dot
      end)
      |> Enum.join("\n")

    dot_links =
      links
      |> Enum.map(fn %Link{dot: dot} ->
        dot
      end)
      |> Enum.join("\n")

    ~s(
      graph {
        node [fontname="helvetica" shape=none];
        graph [fontname="helvetica"];
        edge [fontname="helvetica"];

        splines=curved;
        style=filled;
        K=1.5;

        #{dot_links}

        #{dot_memories}
      }
    )
  end

  defp get_all_memories() do
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

  defp get_links(memories) do
    memories
    |> Enum.filter(fn %Memory{meta: %Meta{links: links}} ->
      case links do
        nil -> false
        _ -> true
      end
    end)
    |> Enum.map(fn %Memory{meta: %Meta{links: memory_links}} ->
      memory_links
    end)
    |> List.flatten()
    # |> Enum.uniq_by(fn %Link{target_id: id} -> id end)
    |> Enum.uniq()
  end
end
