defmodule Chauffeur.Objects.Evader do
  use Scenic.Scene

  import Scenic.Primitives
  import Scenic.Components
  import Math

  alias Chauffeur.Math.Vector2

  def get_relative_coords(e_coords, p_coords, angle) do
    {x_e, y_e} = e_coords
    {x_p, y_p} = p_coords

    {((x_e - x_p) * cos(angle) - (y_e - y_p) * sin(angle)),
     ((y_e - y_p) * cos(angle) + (x_e - x_p) * sin(angle))}
  end

  def move(state) do
    with {:ok, object_map} <- fetch(state, :objects),
         {:ok, {width, height}} <- fetch(state, :scene_size) do
      evader = object_map.evader
      change = Vector2.rotate_evader(car.velocity, car.angle, car.turning_radius)
      new_coords = Vector2.add(change, car.coords)
      history = [new_coords | evader.history]
      object_map = %{object_map | evader: %{evader | coords: new_coords, history: history}}

      state
      |> assign(objects: object_map)
    end
  end

  def update_rotation(state, rotation) do
    {:ok, object_map} = fetch(state, :objects)
    car = %{object_map.car | angle: object_map.car.angle - rotation}

    state
    |> assign(objects: %{object_map | car: car})
  end
 
end
