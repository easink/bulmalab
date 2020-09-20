# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :bulmalab, BulmalabWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qD5ol3m+qOMh4dC6z66GKwQB/9hq0hrDQfxnqJ+O4ThPZ36U1JuWjeI6o7Pv5SyB",
  render_errors: [view: BulmalabWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Bulmalab.PubSub,
  live_view: [signing_salt: "IF3hWRC7V/sXFr9KIR1voY3amE8+5i1Y"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Writing LiveView templates with the .leex extension.
config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
