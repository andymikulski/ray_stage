defmodule RayStageWeb.OutputPageLive do
  use RayStageWeb, :live_view

  @update_fps 24

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # IO.puts "\n\n\n\n CONNECTED \n\n\n\n"
      :ok = Phoenix.PubSub.subscribe(RayStage.PubSub, "pixel_updates")
    end

    {:ok,
      socket
      |> assign(:pending, [])
      |> assign(:has_update_pending?, false)
      } #, temporary_assigns: [pixels: []] }
  end

  # def handle_info({:pixel_updates, incoming_pixels}, %{ assigns: %{pending: []}} = socket) do
  #   Process.send_after(self(), :send_updates, trunc(1000 / @update_fps))
  #   {
  #     :noreply,
  #     socket
  #     |> add_to_pending(incoming_pixels)
  #   }
  # end

  # def handle_info({:pixel_updates, incoming_pixels}, %{ assigns: %{has_update_pending?: true}} = socket) do
  #   {
  #     :noreply,
  #     socket
  #     |> add_to_pending(incoming_pixels)
  #   }
  # ende

  def format_pix({idx, color_tup} = _processed_pixel) do
    [
      idx,
      # [
        (elem(color_tup, 0) * 255) |> trunc(),
        (elem(color_tup, 1) * 255) |> trunc(),
        (elem(color_tup, 2) * 255) |> trunc()
      # ]
    ]
  end

  def handle_info({:pixel_updates, incoming_pixels}, socket) do
    # Process.send_after(self(), :send_updates, 10)
    pending =
      # socket.assigns.pending
      incoming_pixels
      |> Stream.map(&format_pix/1)
      # |> Enum.take(4)
      |> Enum.to_list()
      |> List.flatten()
      # |> Stream.map(fn {idx, color_tup} -> [idx, color_tup |> Tuple.to_list()] end)
      # |> Enum.to_list()
      # |> List.flatten()


    {
      :noreply,
      socket
      |> push_event("pixel_update", %{ pixels: pending})
      # |> add_to_pending(incoming_pixels)
    }
  end

  # def add_to_pending(socket, incoming_pixels) do
  #   socket
  #   |> assign(:has_update_pending?, true)
  #   |> assign(:pending, socket.assigns.pending ++ incoming_pixels)
  # end


  # def handle_info(:send_updates, %{ assigns: %{ pending: []  }} = socket) do
  #   {:noreply, socket}
  # end

  # def handle_info(:send_updates, socket) do
  #   pending =
  #     socket.assigns.pending
  #     |> Enum.map(fn {idx, color_tup} ->
  #       [idx, color_tup |> Tuple.to_list()]
  #     end)

  #   {:noreply,
  #     socket
  #     |> assign(:pending, [])
  #     |> push_event("pixel_update", %{ pixels: pending })
  #     # |> update(:pixels, fn pixels -> pixels ++ incoming_pixels end)
  #   }
  # end
end
