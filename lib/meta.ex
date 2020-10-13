defmodule Brain.Memory.Meta do
  alias __MODULE__

  alias Brain.Helper
  alias Brain.Link
  alias Brain.Memory

  defstruct id: nil,
            title: nil,
            links: nil,
            tags: nil

  def parse(raw) do
    raw_map =
      raw
      |> AtomicMap.convert()

    struct(
      Meta,
      if Map.has_key?(raw_map, :links) do
        %{id: id, links: links} = raw_map

        %{raw_map | links: links |> Enum.map(fn x -> Link.get(id, x) end)}
      else
        raw_map
      end
    )
  end

  def parse_metadata({"pre", [], [{"code", [{"class", ""}], raw_yaml_metadata}]}) do
    case YamlElixir.read_from_string(raw_yaml_metadata) do
      {:ok, raw_metadata} ->
        {:ok,
         %Memory{
           meta: Meta.parse(raw_metadata)
         }
         |> get_dot_node()}

      err ->
        {:error,
         "could not load metadata: #{inspect(err, pretty: true)}, #{
           inspect(raw_yaml_metadata, pretty: true)
         }"}
    end
  end

  defp get_dot_node(%Memory{meta: %Meta{id: id, title: title}} = memory),
    do: %Memory{
      memory
      | dot_node:
          "#{Helper.get_id_for_dot(id)} [label=< #{
            ~w(#{title})
            |> Enum.chunk_every(3)
            |> Enum.map(fn x -> Enum.join(x, " ") end)
            |> Enum.join("<br align=\"center\" />")
          } >];"
    }
end
