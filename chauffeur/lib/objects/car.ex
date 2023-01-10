defmodule Chauffeur.Objects.Car do
  use Scenic.Scene
  import Scenic.Primitives
  import Scenic.Components

  alias Chauffeur.Math.Vector2

  def move(state) do
    {:ok, object_map} = fetch(state, :objects)
    car = object_map.car
    new_pos = Vector2.add(car.coords, car.velocity)
    rotated = Vector2.rotate({10, 0}, car.angle)
    new_coords = Vector2.add(rotated, new_pos)
    object_map = %{object_map | car: %{car | coords: new_coords}}

    state
    |> assign(objects: object_map)
  end

  def update_rotation(state, action) do
    {:ok, object_map} = fetch(state, :objects)
    rotation = action?(action)

    state
    |> assign(
      objects: %{object_map | car: %{object_map.car | angle: object_map.car.angle + rotation}}
    )
  end

  defp action?(0), do: 0
  defp action?(1), do: -20
  defp action?(2), do: 20
end
