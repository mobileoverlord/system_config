# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :system_config, SystemConfig.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+UBuB3QBMkuxX0v4KzHp6eoAdAgdpA+a0ZGvHLLyjJ2VCyUDWTlQLwoPip97J3Fq",
  render_errors: [view: SystemConfig.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SystemConfig.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :system_registry, SystemRegistry.Processor.Config,
  priorities: [:debug]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
