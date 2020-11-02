defmodule RayStage.Orchestrator do
  use GenServer

  def num_ray_workers, do: 4

  def start_link(_options \\ []) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(state) do
    IO.puts "here in 2"
    Process.send_after(self(), :start, 2500)

    {:ok, state}
  end

  @impl true
  def handle_info(:start, state) do
    {:ok, feeder} = RayStage.FeederWorker.start_link()
    {:ok, render} = RayStage.RenderWorker.start_link()

    #        ↗  ray ↘
    # feeder →  ray  → renderer
    #        ↘  ray ↗


    for i <- 0..(num_ray_workers()-1) do
      IO.puts " starting ray #{i}"
      {:ok, ray} = RayStage.RayWorker.start_link()
      GenStage.sync_subscribe(render, to: ray, interval: trunc(1000 / 12))
      GenStage.sync_subscribe(ray, to: feeder, max_demand: trunc(RayStage.Camera.width / 2))
    end

    IO.puts "\n\n\n\n!!!STARTED!!!\n\n\n\n"

    {:noreply, state}
  end
end


# FeederWorker needs a `handle_cast/call` which lets essentially
#  lets us say "we want to render this batch of pixels"

# Feeder sends pixel ranges (and maybe data about the rendering like env?) to RayWorker
# RayWorker casts the ray, handles the collisions, and determines the output color for the given pixel, sends calculated pixels to RenderWorker
# RenderWorker simply reports the results back to the Orchestrator or whoever is subscribed, I guess