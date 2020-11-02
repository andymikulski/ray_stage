
defmodule RayStage.Ray do
  alias Graphmath.Vec3

  defstruct [
    :origin,
    :direction,
  ]

  def create(origin, direction) when is_tuple(origin) and is_tuple(direction) do
    %__MODULE__{
      origin: origin,
      direction: direction,
    }
  end

  def project(%__MODULE__{} = ray, time) when time |> is_number() do
    ray.origin
    |> Vec3.add(Vec3.scale(ray.direction, time))
  end
end