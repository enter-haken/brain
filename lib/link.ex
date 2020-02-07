defmodule Brain.Link do
  alias __MODULE__
  alias Brain.Helper

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
end
