defmodule Chauffeur.Scene.Environment do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Chauffeur.Math.Vector2
  alias Chauffeur.Objects.{Car, Evader}

  import Scenic.Primitives
  import Scenic.Components

  @car_width 15
  @car_height 25
  @car_velocity 3
  @car_turning_radius 2

  @impl true
  def init(scene, _param, _opts) do
    {width, height} = scene.viewport.size
    # Initial car pos
    {pos_x, pos_y} = {trunc(width / 4), trunc(height / 2)}

    scene =
      scene
      |> assign(
        frame_count: 0,
        scene_size: {width, height},
        objects: %{
          car: %{
            dimension: %{width: @car_width, height: @car_height},
            coords: {pos_x, pos_y},
            velocity: @car_velocity,
            turning_radius: @car_turning_radius,
            angle: 0,
            history: [{pos_x, pos_y}]
          },
          evader: %{
            coords: {pos_x + 200, pos_y},
            velocity: {-1, -1},
            angle: 0,
            history: [{pos_x + 200, pos_y}]
          }
        },
        graph:
          Graph.build()
          |> button("start", translate: {10, 10}, id: :btn)
      )

    request_input(scene, :key)
    {:ok, graph} = fetch(scene, :graph)
    scene = scene |> push_graph(draw_objects(graph, scene))
    {:ok, scene}
  end

  @impl true
  def handle_event({:click, :btn}, _from, scene) do
    with {:ok, graph} <- fetch(scene, :graph),
         {:ok, timer} <- :timer.send_interval(60, :frame) do
      graph =
        Graph.modify(
          graph,
          :btn,
          &button(&1, "start", translate: {10, 10}, hidden: true, id: :btn)
        )

      scene =
        scene
        |> assign(
          timer: timer,
          graph: graph
        )

      {:cont, :ok, scene}
    end
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
          |> rect({width, height}, fill: :blue, translate: {x - width / 2, y - height / 2})
        end,
        rotate: -angle_radians * @car_velocity / @car_turning_radius,
        pin: {x, y},
        id: :car
      )
      |> path(get_obj_path(data.history),
        stroke: {3, :pink}
      )
  end

  defp draw_object(graph, :evader, data) do
    {x, y} = data.coords
    angle_radians = data.angle |> Vector2.degrees_to_radians()

    new_graph =
      graph
      |> group(
        fn g ->
          g
          |> circle(4, fill: :red, translate: {x, y})
        end,
        rotate: angle_radians,
        pin: {x, y},
        id: :evader
      )
      |> path(get_obj_path(data.history),
        stroke: {3, :green}
      )
  end

  defp get_obj_path([start | rest] = history) do
    {start_x, start_y} = start

    [{:move_to, start_x, start_y}] ++
      Enum.map(rest, fn {x, y} -> {:line_to, x, y} end)
  end

  def handle_info(:frame, state) do

    with {:ok, objects} <- fetch(state, :objects),
         {:ok, frame_count} <- fetch(state, :frame_count),
         {:ok, graph} <- fetch(state, :graph) do
      # Check if game ended
      {x_p, y_p} = objects.car.coords
      {x_e, y_e} = objects.evader.coords

      new_state =
        if rem(frame_count, 1) == 0 do
          state
          |> Car.move()
          |> Evader.move()
        else
          state
        end

      graph =
        graph
        |> draw_objects(new_state)

      new_state = new_state |> push_graph(graph)

      if abs(x_p - x_e) < @car_width && abs(y_p - y_e) < @car_height do
        {:ok, timer} = fetch(state, :timer)
        :timer.cancel(timer)
        {:stop, :normal, []}
      else
        {:noreply, new_state}
      end
    end
  end

  # Keyboard controls
  @impl true
  def handle_input({:key, {:key_left, _, _}}, _context, state) do
    {:noreply, Car.update_rotation(state, 1)}
  end

  @impl true
  def handle_input({:key, {:key_right, _, _}}, _context, state) do
    {:noreply, Car.update_rotation(state, -1)}
  end
end
