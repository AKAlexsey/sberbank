# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sberbank,
  ecto_repos: [Sberbank.Repo]

# Configures the endpoint
config :sberbank, SberbankWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tv//srWrWDtxLIHnHS+GOpppqKDis6zvvGmRaroZhaZxE1wPZtISeo2OfTLagU0q",
  render_errors: [view: SberbankWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Sberbank.PubSub,
  live_view: [signing_salt: "EEu59h4f"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"