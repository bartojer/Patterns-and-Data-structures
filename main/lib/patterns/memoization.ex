defmodule ShippingCost do
  def cost(map, weight, dist) do
    key = {weight, dist}

    case Map.fetch(map, key) do
      {:ok, value} ->
        {map, value}

      :error ->
        value = compute_cost(weight, dist)

        {Map.put(map, key, value), value}
    end
  end

  def compute_cost(weight, dist), do: 5.0 + weight * 1.2 + dist * 0.25
end
