defmodule Chauffeur.Objects.Evader do
  use Scenic.Scene
  import Scenic.Primitives
  import Scenic.Components

  alias Chauffeur.Math.Vector2

  def move(state) do
    with {:ok, object_map} <- fetch(state, :objects),
         {:ok, {width, height}} <- fetch(state, :scene_size) do
      evader = object_map.evader
      new_coords = Vector2.add(evader.coords, evader.velocity)
      history = [new_coords | evader.history]
      object_map = %{object_map | evader: %{evader | coords: new_coords, history: history}}

      state
      |> assign(objects: object_map)
    end
  end
end
