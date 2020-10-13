defmodule Brain do
  require Logger

  alias Brain.Memory
  alias Brain.Memory.Meta
  alias Brain.Link
  alias Brain.Graph
  alias Brain.Persist

  def main(args) do
    {parsed_args, _, _} =
      args
      |> OptionParser.parse(
        strict: [
          search: :string,
          tag: :string,
          all: :boolean,
          ast: :boolean
        ]
      )

    parsed_args
    |> Map.new()
    |> execute()
    |> IO.puts()
  end

  defp execute(%{ast: true}) do
    inspect(Persist.get_all_memories(), pretty: true)
  end

  defp execute(%{all: true}) do
    all_memories = Persist.get_all_memories()

    Graph.get(
      all_memories,
      all_memories |> Link.get()
    )
  end

  defp execute(%{tag: tag}) do
    all_memories = Persist.get_all_memories()

    found_memories =
      all_memories
      |> Enum.filter(fn memory ->
        memory
        |> Memory.has_tag?(tag)
      end)

    linked_memories =
      found_memories
      |> Link.get()
      |> Enum.map(fn %Link{target_id: target_id} ->
        all_memories
        |> Enum.find(fn %Memory{meta: %Meta{id: id}} -> id == target_id end)
      end)

    Graph.get(
      (found_memories ++ linked_memories)
      |> Enum.uniq_by(fn %Memory{meta: %Meta{id: id}} -> id end),
      found_memories |> Link.get()
    )
  end

  defp execute(%{search: search}) do
    all_memories = Persist.get_all_memories()

    # TODO:
    # markdown to ast
    # |> exclude urls from "fulltext search"

    found_memories =
      all_memories
      |> Memory.find(search)

    linked_memories =
      all_memories
      |> Memory.get_linked_memories(found_memories)

    # every memory, having a link to the found memory
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
      |> Kernel.++(found_memories |> Link.get())
      |> Enum.uniq()

    Graph.get(
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
end
