defmodule Chauffeur.Scene.Environment do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Chauffeur.Math.Vector2

  import Scenic.Primitives
  # import Scenic.Components

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do
    # get the width and height of the viewport. This is to demonstrate creating
    # a transparent full-screen rectangle to catch user input
    {width, height} = scene.viewport.size

    graph = Graph.build(theme: :light)

    # Initial car pos
    {pos_x, pos_y} = {trunc(width / 2), trunc(height / 2)}

    scene = scene
    |> assign(
      objects: %{
        car: %{
          dimension: %{width: 50, height: 30},
          coords: {pos_x, pos_y},
          velocity: {1, 0},
          angle: 0
        }
      }, graph: graph
    )

    graph = draw_objects(graph, scene)

    scene = scene |> push_graph(graph)

    {:ok, scene}
  end

  def handle_input(event, _context, scene) do
    Logger.info("Received event: #{inspect(event)}")
    {:noreply, scene}
  end

  defp draw_objects(graph, scene) do
    {:ok, object_map} = fetch(scene, :objects)
    Enum.reduce(object_map, graph, fn {object_type, object_data}, graph ->
      draw_object(graph, object_type, object_data)
    end)
  end

  defp draw_object(graph, :car, data) do
    %{width: width, height: height} = data.dimension
    {x, y} = data.coords
    angle_radians = data.angle |> Vector2.degrees_to_radians()
    new_graph =
      graph
      |> group(fn(g) ->
        g
        |> rect({width, height}, [fill: :red, translate: {x, y}])
        |> circle(16, fill: :blue, translate: {x + 58, y + 15}, id: :caputre_area)
      end, rotate: angle_radians, pin: {x, y}, id: :car)
  end

end
