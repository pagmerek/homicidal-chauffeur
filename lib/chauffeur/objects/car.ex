defmodule Chauffeur.Objects.Car do
  use Scenic.Scene
  require Logger
  import Scenic.Primitives
  import Scenic.Components
  import Math

  alias Chauffeur.Math.Vector2
  alias Chauffeur.Math.PythonWorker

  def sign(x) do
    cond do
      x > 0 -> 1
      x < 0 -> -1
      true -> 0
    end
  end

  def move(state) do
    with {:ok, object_map} <- fetch(state, :objects),
         {:ok, {width, height}} <- fetch(state, :scene_size) do
      car = object_map.car
      w = car.velocity
      u = car.u

      u =
        if abs(car.u) > 1 do
          u = sign(u)
        else
          car.u
        end

      r = car.turning_radius
      angle = car.angle
      u = u * (w / r)
      change = {w * sin(angle + u), w * cos(angle + u)}
      new_coords = Vector2.add(change, car.coords)
      history = [new_coords | car.history]

      object_map = %{
        object_map
        | car: %{car | coords: new_coords, history: history, angle: angle + u}
      }

      state
      |> assign(objects: object_map)
    end
  end

  def update_controls(state) do
    {:ok, object_map} = fetch(state, :objects)
    car = object_map.car
    evader = object_map.evader
    {x_c, y_c} = car.coords
    {x_e, y_e} = evader.coords
    heading_angle = car.angle
    angle = Vector2.atan2(y_e - y_c, x_e - x_c)
    u = Math.pi() / 2 - angle - heading_angle

    state
    |> assign(objects: %{object_map | car: %{car | u: u / (car.velocity / car.turning_radius)}})
  end
end
