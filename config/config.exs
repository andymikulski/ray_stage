# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config



config :ray_stage_web,
  generators: [context_app: :ray_stage]

# Configures the endpoint
config :ray_stage_web, RayStageWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/aBlHjso9HTwikoUMDTCSe4ui3tMpRkEIuYS0H/wccRrzONOV14lw+Z/5X3yXYaY",
  render_errors: [view: RayStageWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RayStage.PubSub,
  live_view: [signing_salt: "nrc1k9D8"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
