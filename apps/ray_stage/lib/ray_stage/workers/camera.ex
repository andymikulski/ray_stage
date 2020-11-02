defmodule RayStage.Camera do
  alias Graphmath.Vec3

  def width, do: 640 #trunc(320 * (16/9))
  def height, do: 480 # 320

  def get_info() do
    aspect_ratio = __MODULE__.width / __MODULE__.height
    image_width = __MODULE__.width
    image_height = (image_width / aspect_ratio) |> Kernel.trunc()
    viewport_height = 2.0
    viewport_width = aspect_ratio * viewport_height
    focal_length = 1.0

    origin = Vec3.create(0, 0, 0)
    horizontal = Vec3.create(viewport_width, 0, 0)
    vertical = Vec3.create(0, viewport_height, 0)
    lower_left_corner_vec =
      origin
      |> Vec3.subtract( Vec3.scale(horizontal, 0.5))
      |> Vec3.subtract( Vec3.scale(vertical, 0.5))
      |> Vec3.subtract(Vec3.create(0, 0, focal_length))

    %{
      image_width: image_width,
      image_height: image_height,
      origin: origin,
      horizontal: horizontal,
      vertical: vertical,
      lower_left_corner_vec: lower_left_corner_vec
    }
  end
end