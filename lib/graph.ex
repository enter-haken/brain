defmodule Brain.Graph do
  alias Brain.{Memory, Link}

  def get(memories, links) do
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
end
