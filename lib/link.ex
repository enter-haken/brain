defmodule Brain.Link do
  alias __MODULE__
  alias Brain.{Memory, Memory.Meta, Helper}

  defstruct target_id: nil,
            source_id: nil,
            dot: nil

  def get(source_id, target_id) do
    %Link{
      target_id: target_id,
      source_id: source_id,
      dot: "#{Helper.get_id_for_dot(source_id)} -- #{Helper.get_id_for_dot(target_id)};"
    }
  end

  def get(memories),
    do:
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
      |> Enum.uniq()
end
