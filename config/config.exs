use Mix.Config

config :brain,
  memory_paths: ["priv/memories/"]

config :logger,
  level: :debug

import_config "config.#{Mix.env()}.exs"
