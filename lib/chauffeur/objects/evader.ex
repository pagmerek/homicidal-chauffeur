defmodule Chauffeur.Objects.Evader do
  use Scenic.Scene

  import Scenic.Primitives
  import Scenic.Components
  import Math

  alias Chauffeur.Math.Vector2

  def get_relative_coords(e_coords, p_coords, angle) do
    {x_e, y_e} = e_coords
    {x_p, y_p} = p_coords

    {(x_e - x_p) * cos(angle) - (y_e - y_p) * sin(angle),
     (y_e - y_p) * cos(angle) + (x_e - x_p) * sin(angle)}
  end

  def move(state) do
    with {:ok, object_map} <- fetch(state, :objects),
         {:ok, {width, height}} <- fetch(state, :scene_size) do
      evader = object_map.evader
      w = evader.velocity
      angle = evader.angle
      change = {w * sin(angle), w * cos(angle)}
      new_coords = Vector2.add(change, evader.coords)
      history = [new_coords | evader.history]
      object_map = %{object_map | evader: %{evader | coords: new_coords, history: history}}

      state
      |> assign(objects: object_map)
    end
  end

  def update_rotation(state, rotation) do
    {:ok, object_map} = fetch(state, :objects)
    evader = %{object_map.evader | angle: rotation}

    state
    |> assign(objects: %{object_map | evader: evader})
  end

  def update_controls(state) do
    {:ok, object_map} = fetch(state, :objects)
    car = object_map.car
    evader = object_map.evader
    {x_c, y_c} = car.coords
    {x_e, y_e} = evader.coords
    heading_angle = car.angle

    angle = Vector2.atan2(y_e - y_c, x_e - x_c)

    state
    |> assign(objects: %{object_map | evader: %{object_map.evader | angle: angle}})
  end
end
