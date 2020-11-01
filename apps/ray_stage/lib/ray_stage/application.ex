defmodule RayStage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: RayStage.PubSub},
      # Start a worker by calling: RayStage.Worker.start_link(arg)
      # {RayStage.Worker, arg}
      RayStage.Orchestrator
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: RayStage.Supervisor)
  end
end
