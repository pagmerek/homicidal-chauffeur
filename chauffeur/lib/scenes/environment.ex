defmodule Chauffeur.Scene.Environment do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Chauffeur.Math.Vector2
  alias Chauffeur.Objects.Car

  import Scenic.Primitives

  def init(scene, _param, _opts) do
    {width, height} = scene.viewport.size

    graph = Graph.build(theme: :light)

    # Initial car pos
    {pos_x, pos_y} = {trunc(width / 2), trunc(height / 2)}

    scene =
      scene
      |> assign(
        frame_count: 0,
        objects: %{
          car: %{
            dimension: %{width: 50, height: 30},
            coords: {pos_x, pos_y},
            velocity: {1, 0},
            angle: 0
          },
          evader: %{
            dimension: %{width: 10, height: 30},
            coords: {pos_x + 100, pos_y},
            velocity: {1, 0},
            angle: 0
          }
        },
        graph: graph
      )

    graph = draw_objects(graph, scene)

    scene = scene |> push_graph(graph)

    {:ok, timer} = :timer.send_interval(60, :frame)

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
      |> group(
        fn g ->
          g
          |> circle(16, fill: :peach_puff, translate: {x + 58, y + 15}, id: :caputre_area)
          |> rect({width, height}, fill: :honey_dew, translate: {x, y})
        end,
        rotate: angle_radians,
        pin: {x, y},
        id: :car
      )
  end

  defp draw_object(graph, :evader, data) do
    %{width: width, height: height} = data.dimension
    {x, y} = data.coords
    angle_radians = data.angle |> Vector2.degrees_to_radians()

    new_graph =
      graph
      |> group(
        fn g ->
          g
          |> rect({width, height}, fill: :black, translate: {x + 10, y})
          |> circle(6, fill: :orange, translate: {x + 15, y + 15}, id: :caputre_area)
        end,
        rotate: angle_radians,
        pin: {x, y},
        id: :evader
      )
  end

  def handle_info(:frame, state) do
    {:ok, objects} = fetch(state, :objects)
    {:ok, frame_count} = fetch(state, :frame_count)
    {:ok, graph} = fetch(state, :graph)

    new_state =
      if rem(frame_count, 2) == 0 do
        state |> Car.move()
      else
        state
      end

    graph =
      graph
      |> draw_objects(new_state)

    new_state = new_state |> push_graph(graph)

    {:noreply, new_state}
  end
end
