defmodule RayStage.FeederWorker do
  use GenStage

  def start_link(options \\ []) do
    width = options |> Keyword.get(:width, RayStage.Camera.width)
    height = options |> Keyword.get(:height, RayStage.Camera.height)

    GenStage.start_link(__MODULE__, %{
      width: width,
      height: height,
      cursor: 0,
      max_index: (width * height) - 1,
    })
  end

  def init(state) do
    {:producer, state}
  end

  def handle_demand(demand, %{ cursor: cursor, max_index: max_index } = state) when demand > 0 do
    # If the counter is 3 and we ask for 2 items, we will
    # emit the items 3 and 4, and set the state to 5.
    next_cap = min(max_index, cursor+demand-1)
    pixel_queue = Enum.to_list(cursor..next_cap)
    {:noreply, pixel_queue, state |> Map.put(:cursor, next_cap)}
  end
end