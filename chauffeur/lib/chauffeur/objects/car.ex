defmodule Chauffeur.Objects.Car do
  use Scenic.Scene
  require Logger
  import Scenic.Primitives
  import Scenic.Components

  alias Chauffeur.Math.Vector2
  alias Chauffeur.Math.PythonWorker

  def move(state) do
    with {:ok, object_map} <- fetch(state, :objects),
         {:ok, {width, height}} <- fetch(state, :scene_size) do
      car = object_map.car
      change = Vector2.rotate_car(car.velocity, car.angle, car.turning_radius)
      new_coords = Vector2.add(change, car.coords)
      history = [new_coords | car.history]
      object_map = %{object_map | car: %{car | coords: new_coords, history: history}}

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
