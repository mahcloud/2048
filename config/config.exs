# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :twenty,
  ecto_repos: [Twenty.Repo]

# Configures the endpoint
config :twenty, TwentyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EV9iK/Les9ZSAeaoFvWmYKlV11RMg7iqSxKSE7TwIyuWax4Lj0QHfR4mtC7u7IDD",
  render_errors: [view: TwentyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Twenty.PubSub,
  live_view: [signing_salt: "Dj60Ckby"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
