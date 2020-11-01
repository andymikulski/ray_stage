defmodule RayStage.RenderWorker do
  use GenStage

  def start_link(_opts \\ []) do
    GenStage.start_link(__MODULE__, nil)
  end

  def init(_state) do
    {:consumer, :the_state_does_not_matter}
  end

  def handle_events(pixels, _from, state) do
    # IO.puts " got pixels for rendering.. "
    # IO.inspect(pixels, label: "got pixels...")

    # outgoing =
      # pixels
      # |> Stream.map(&Kernel.elem(&1, 1))
      # |> Stream.chunk_every(RayStage.Camera.width)
      # |> Stream.map(&Enum.join(&1, ""))
      # |> Stream.map(&IO.inspect/1)
      # |> Enum.to_list()

    Phoenix.PubSub.broadcast(RayStage.PubSub, "pixel_updates", {:pixel_updates, pixels})

    # Wait for a second.
    # Process.sleep(1000)
    # Inspect the events.
    # IO.inspect(events)

    # We are a consumer, so we would never emit items.
    {:noreply, [], state}
  end

  def get_brightness({_idx, {r, g, b}}) do
    brightness = (0.299*r) + (0.587*g) + (0.114*b)

    # cond do
    #   brightness <= 85 -> "░"
    #   brightness > 85 and brightness < 170 -> "▒"
    #   true -> "▓"
    # end

    cond do
      brightness <= 0.3333 -> "C"
      brightness > 0.3333 and brightness <= 0.6666 -> "B"
      true -> "A"
    end

  end
end