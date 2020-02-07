defmodule Brain.Memory do
  alias __MODULE__

  alias Brain.Memory.Meta
  alias Brain.Link

  require Logger

  defstruct meta: nil,
            content: nil,
            markdown: nil,
            dot_node: nil

  def get(markdown) do
    with {:ok, [metadata | raw_ast_content], _errors} <- Earmark.as_ast(markdown),
         {:ok, memory} <- parse_metadata(metadata) do
      content =
        raw_ast_content
        |> Earmark.Transform.transform()

      {:ok,
       %Memory{memory | content: content, markdown: markdown, dot_node: get_dot_node(memory)}}
    else
      err ->
        {:error, "could not create memory: #{inspect(err, pretty: true)}"}
    end
  end

  def contains?(%Memory{markdown: markdown}, search_phrase),
    do:
      String.contains?(
        String.downcase(markdown),
        search_phrase |> String.trim() |> String.downcase()
      )

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

  defp parse_metadata({"pre", [], [{"code", [{"class", ""}], raw_yaml_metadata}]}) do
    case YamlElixir.read_from_string(raw_yaml_metadata) do
      {:ok, raw_metadata} ->
        {:ok,
         %Memory{
           meta: Meta.parse(raw_metadata)
         }}

      err ->
        {:error,
         "could not load metadata: #{inspect(err, pretty: true)}, #{
           inspect(raw_yaml_metadata, pretty: true)
         }"}
    end
  end

  defp get_dot_node(%Memory{meta: meta}),
    do: Meta.get_dot_node(meta)
end
