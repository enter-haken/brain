defmodule Brain.Helper do
  def bash(script), do: System.cmd("sh", ["-c", script])

  def get_id_for_dot(id), do: "x#{id |> String.replace("-", "")}"
end
