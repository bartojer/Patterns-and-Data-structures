defmodule HelpSup do
  def assign(children, id) do
    {_, pid, _, _} = Enum.find(children, fn {x, _, _, _} -> x == id end)
    pid
  end
end
