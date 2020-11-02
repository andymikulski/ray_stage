defmodule RayStage.RayWorker do
  use GenStage
  alias RayStage.Ray
  alias Graphmath.Vec3

  def start_link(opts \\ nil) do
    GenStage.start_link(__MODULE__, opts)
  end

  def init(state) do
    {:producer_consumer, state}
  end

  def hit_sphere(center, radius, %Ray{} = ray) when center |> is_tuple() do
    oc =
      ray.origin
      |> Vec3.subtract(center)

    a = Vec3.dot( ray.direction, ray.direction )
    b = 2.0 * Vec3.dot(oc, ray.direction)
    c = Vec3.dot(oc, oc) - (radius * radius)

    discriminant = b*b - 4*a*c

    if (discriminant < 0) do
      -1.0
    else
      (-b - :math.sqrt(discriminant) ) / (2.0*a)
    end
  end

  def ray_color(%Ray{} = ray) do
    hit_t = hit_sphere(Vec3.create(0, 0, -1), 0.5, ray)
    cond do
      hit_t >= 0 ->
        {nX, nY, nZ} =
          Ray.project(ray, hit_t)
          |> Vec3.subtract(Vec3.create(0,0,-1))
          |> Vec3.normalize()

        Vec3.create(nX, nY, nZ)
        |> Vec3.scale(0.5)
        # Vec3.create(1, 0, 0)
      true -> background_color(ray)
    end
  end

  def background_color(%Ray{} = ray) do
    unit_y =
      ray.direction
      |> Vec3.normalize()
      |> elem(1)

    t = 0.5 * (unit_y + 1.0)

    # (1.0-t)*Vec3.create(1.0, 1.0, 1.0)
    part1 =
      Vec3.create(1.0, 1.0, 1.0)
      |> Vec3.scale(1.0 - t)

    # t*Vec3.create(0.5, 0.7, 1.0)
    part2 =
      Vec3.create(0.5, 0.7, 1.0)
      |> Vec3.scale(t)

    # Return the combination of parts
    Vec3.add(part1, part2)
  end

  def handle_events(pixel_queue, _from, state) do
    # pixel_queue = Enum.map(pixel_queue, & &1 * state)

    camera_info = RayStage.Camera.get_info()


    output =
      for pix_idx <- pixel_queue do
        {pix_idx, average_ray(camera_info, pix_idx, 4)}
      end

    # simulate complex work
    # Process.sleep(250 * Enum.random(1..9))

    {:noreply, output, state}
  end

  def blend_colors({oR, oG, oB} = color_one, {tR, tG, tB} = color_two, amount \\ 0.8 ) do
    {
      :math.sqrt(((1 - (amount)) * (oR * oR)) + ((amount) * (tR * tR))),
      :math.sqrt(((1 - (amount)) * (oG * oG)) + ((amount) * (tG * tG))),
      :math.sqrt(((1 - (amount)) * (oB * oB)) + ((amount) * (tB * tB)))
    }
  end

  def random_offset() do
    :rand.uniform()
    |> Kernel.*(if :rand.uniform() < 0.5, do: -1, else: 1)
  end

  def average_ray(camera_info, pix_idx, iterations \\ 4) do
    %{
      origin: origin,
      horizontal: horizontal,
      vertical: vertical,
      lower_left_corner_vec: lower_left_corner_vec,
      image_width: image_width,
      image_height: image_height,
    } = camera_info

    (1..iterations)
    |> Enum.reduce(Vec3.create(0,0,0), fn(_iter, acc) ->
      y = (pix_idx / image_width) |> trunc()
      x = pix_idx - (y * image_width)

      u = (x + (random_offset() * 1)) / (image_width-1)
      v = (y + (random_offset() * 1)) / (image_height-1)

      ray_dir =
        lower_left_corner_vec
        |> Vec3.add(  Vec3.scale(horizontal, u) )
        |> Vec3.add(  Vec3.scale(vertical, v) )
        |> Vec3.subtract(origin)

      ray = Ray.create(origin, ray_dir)

      acc
      |> blend_colors(ray_color(ray), 0.25)
    end)

  end

end
