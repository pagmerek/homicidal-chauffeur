defmodule Chauffeur.Scene.Environment do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Chauffeur.Math.{Vector2, PythonWorker}
  alias Chauffeur.Objects.{Car, Evader}

  import Scenic.Primitives
  import Scenic.Components

  @car_width 15
  @car_height 25
  @car_velocity 3
  @car_turning_radius 3
  @evader_max_velocity 0.3

  @impl true
  def init(scene, _param, _opts) do
    {width, height} = scene.viewport.size
    # Initial car pos
    {pos_x, pos_y} = {trunc(width / 2), trunc(height / 4)}

    p_control = [
      -0.29882742,
      -1,
      -0.20281769,
      -0.90005355,
      -0.72433803,
      -0.27099147,
      -0.99940299,
      0.24180379,
      -0.18215633,
      -0.98381305,
      -0.67516692,
      -0.54566096,
      -0.99921953,
      -0.80552329,
      -0.29232394,
      -0.78884173,
      0.27599067,
      -1,
      -1,
      0.62742594,
      0.66236266,
      -0.99948484,
      -0.81516993,
      -0.56712831,
      -0.3698168,
      -1,
      0.39374549,
      -1,
      -0.99940181,
      -0.44046442,
      0.79364017,
      0.88234033,
      -0.99835771,
      0.90586885,
      -0.99904957,
      -0.22059468,
      0.091511,
      0.64071367,
      -1,
      -0.266574,
      0.04002133,
      0.33541347,
      -1,
      0.99999997,
      -0.22189501,
      -0.36787491,
      -1,
      -0.14488025,
      -0.54632957,
      0.83519164,
      -1,
      0.99999996,
      -1,
      -1,
      0.49931321,
      -1,
      1,
      0.66349033,
      0.86314551,
      -0.25749028,
      0.26563066,
      -1,
      0.99999996,
      0.18152077,
      -1,
      0.36601144,
      -1,
      -0.09653345,
      0.45671763,
      -1,
      0.99965981,
      -1,
      -0.99570724,
      0.30136156,
      -1,
      -0.73889194,
      -0.62267475,
      -0.13465874,
      -0.5957979,
      -0.4403858,
      0.65788802,
      -0.99999997,
      0.03445438,
      -0.6380244,
      -0.2594188,
      -0.43383335,
      -0.76480736,
      -0.08241777,
      -0.38183216,
      -0.24335242,
      -0.09689322,
      0.33140725,
      0.51470717,
      -1,
      0.99999996,
      0.00893225,
      -0.01526418,
      -0.02728556,
      0.0020635,
      -0.01782765,
      0.00270548
    ]

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
            u: p_control,
            history: [{pos_x, pos_y}]
          },
          evader: %{
            coords: {pos_x + 200, pos_y - 30},
            velocity: {1, 1},
            angle: 0,
            history: [{pos_x + 200, pos_y - 30}]
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
         {:ok, timer} <- :timer.send_interval(100, :frame) do
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
      angle = objects.car.angle

      time = frame_count / 10
      evader = objects.evader
      car = objects.car

      z0 =
        Evader.get_relative_coords(
          evader.coords,
          car.coords,
          car.velocity / car.turning_radius * car.angle
        )

      # {:ok, {u, v1, v2}} = PythonWorker.get_controls(
      #   time,
      #   z0,
      #   @car_velocity,
      #   @evader_max_velocity,
      #   @car_turning_radius,
      #   evader.velocity,
      #   car.u
      # )
      # Logger.info(inspect({u, v1, v2}))
      control = Enum.at(objects.car.u, div(frame_count,100))
      new_state =
        state
        #    |> assign(objects: %{objects | car: %{car | u: u}})
        |> Car.update_rotation(control)
        |> Car.move()
        # |> Evader.update_velocity(v1, v2)
        |> Evader.move()

      new_state =
        new_state
        |> assign(frame_count: frame_count + 1)
        |> push_graph(draw_objects(graph, new_state))

      if abs(x_p - x_e) < @car_width / 2 && abs(y_p - y_e) < @car_height / 2 do
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

  @impl true
  def handle_input({:key, {:key_w, _, _}}, _context, state) do
    {:ok, object} = fetch(state, :objects)
    evader = object.evader

    {:noreply, state |> assign(objects: %{object | evader: %{evader | velocity: {0, -1}}})}
  end

  @impl true
  def handle_input({:key, {:key_a, _, _}}, _context, state) do
    {:ok, object} = fetch(state, :objects)
    evader = object.evader

    {:noreply, state |> assign(objects: %{object | evader: %{evader | velocity: {-1, 0}}})}
  end

  @impl true
  def handle_input({:key, {:key_t, _, _}}, _context, state) do
    {:ok, object} = fetch(state, :objects)
    {:ok, frames} = fetch(state, :frame_count)
    time = frames / 10
    evader = object.evader
    car = object.car
    z0 = Evader.get_relative_coords(object.evader.coords, object.car.coords, car.angle)

    {:ok, s} =
      PythonWorker.get_controls(
        time,
        z0,
        @car_velocity,
        @evader_max_velocity,
        @car_turning_radius,
        evader.velocity,
        car.u
      )

    Logger.info("solved: #{inspect(s)} current: #{inspect(z0)}")
    {:noreply, state |> assign(objects: %{object | evader: %{evader | velocity: {-1, 0}}})}
  end

  @impl true
  def handle_input({:key, {:key_s, _, _}}, _context, state) do
    {:ok, object} = fetch(state, :objects)
    evader = object.evader

    {:noreply, state |> assign(objects: %{object | evader: %{evader | velocity: {0, 1}}})}
  end

  @impl true
  def handle_input({:key, {:key_d, _, _}}, _context, state) do
    {:ok, object} = fetch(state, :objects)
    evader = object.evader

    {:noreply, state |> assign(objects: %{object | evader: %{evader | velocity: {1, 0}}})}
  end

  @impl true
  def handle_input({:key, {:key_space, _, _}}, _context, state) do
    {:ok, object} = fetch(state, :objects)
    car = object.car

    {:noreply, state |> assign(objects: %{object | car: %{car | velocity: 0}})}
  end
end
