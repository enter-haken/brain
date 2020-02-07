defmodule Brain.Memory.Meta do
  alias __MODULE__

  alias Brain.Helper
  alias Brain.Link

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

  def get_dot_node(%Meta{id: id, title: title}) do
    dot_title =
      ~w(#{title})
      |> Enum.chunk_every(3)
      |> Enum.map(fn x -> Enum.join(x, " ") end)
      |> Enum.join("<br align=\"center\" />")

    "#{Helper.get_id_for_dot(id)} [label=< #{dot_title} >];"
  end
end
