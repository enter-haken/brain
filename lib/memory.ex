defmodule Brain.Memory do
  alias __MODULE__

  alias Brain.Memory.Meta
  alias Brain.Link

  require Logger

  # TODO:
  # * create pdfs from external links
  #   * use headles chrome

  defstruct meta: nil,
            content: nil,
            markdown: nil,
            dot_node: nil

  def get(markdown) do
    with {:ok, [metadata | raw_ast_content], _errors} <- Earmark.as_ast(markdown),
         {:ok, memory} <- Meta.parse_metadata(metadata) do
      content =
        raw_ast_content
        |> Earmark.Transform.transform()

      {:ok, %Memory{memory | content: content, markdown: markdown}}
    else
      err ->
        {:error, "could not create memory: #{inspect(err, pretty: true)}"}
    end
  end

  def contains?(%Memory{markdown: markdown}, search_phrase) do
    search_phrase_word_list =
      ~w(#{search_phrase})
      |> Enum.map(fn x -> String.downcase(x) end)

    raw_memory_word_list =
      ~w(#{markdown})
      |> Enum.map(fn x -> String.downcase(x) end)

    length(raw_memory_word_list) != length(raw_memory_word_list -- search_phrase_word_list)
  end

  def is_linked?(%Memory{meta: %{id: id}} = _child, %Memory{meta: %{links: links}} = _parent) do
    if(is_nil(links)) do
      false
    else
      links
      |> Enum.map(fn %Link{target_id: link_id} -> link_id end)
      |> Enum.any?(fn x -> x == id end)
    end
  end

  def has_tag?(%Memory{meta: %Meta{tags: tags}} = _child, tag) do
    if(is_nil(tags)) do
      false
    else
      tags
      |> Enum.any?(fn x -> String.contains?(String.downcase(x), String.downcase(tag)) end)
    end
  end

  def find(memories, search_phrase) do
    memories
    |> Enum.filter(fn memory ->
      memory
      |> Memory.contains?(search_phrase)
    end)
  end

  def get_linked_memories(memories, found_memories) do
    found_memories
    |> Link.get()
    |> Enum.map(fn %Link{target_id: target_id} ->
      memories
      |> Enum.find(fn %Memory{meta: %Meta{id: id}} -> id == target_id end)
    end)
  end
end
